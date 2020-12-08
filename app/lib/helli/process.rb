# frozen_string_literal: true

require 'open3'

# Creates child processes to run commands.
class Helli::Process
  attr_reader :wd, :cmd, :stdin, :exitstatus
  attr_accessor :stdout, :stderr, :other

  # Creates a Process in at given working directory.
  def initialize(wd = Dir.pwd)
    @wd = File.absolute_path(wd)
  end

  # Opens a process and captures the standard output and the standard error of a command.
  # Raises Timeout::Error if process timeout is exceeded. Returns itself.
  def open(*cmd, stdin: nil, timeout: 10)
    @cmd = cmd.join(' ').strip

    Open3.popen3(@cmd, chdir: @wd) do |i, o, e, t|
      if stdin
        @stdin = stdin
        i.puts(stdin)
        i.close
      end

      begin
        Timeout.timeout(timeout) do
          @stdout = o.read
          @stderr = e.read
          @exitstatus = t.value.exitstatus
        end
      rescue Timeout::Error
        Process.kill('KILL', t.pid)
        raise Timeout::Error, "process timeout (#{timeout} seconds) exceeded"
      end
    end

    self
  end

  # Behaves as same as Helli::Process#open, but also raises Helli::Process::Error if the process exits with a non-zero status.
  def open!(*cmd, stdin: '', timeout: 5)
    self.open(*cmd, stdin: stdin, timeout: timeout)
    raise Helli::Process::Error, "#{@cmd}:\n#{@stderr}" unless @exitstatus.zero?

    self
  end

  class Error < StandardError; end
end
