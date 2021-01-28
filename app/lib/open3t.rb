# frozen_string_literal: true

# Timeout versions of capture* family, based on built-in open3 module.
module Open3t
  class << self
    Thread.abort_on_exception = true
    Thread.report_on_exception = false

    # Open3t.capture3t captures the standard output and the standard error of a command within a given timeout.
    #
    # Process will return nil if timeout is reached.
    #   Open3t.capture3t[2].exitstatus #=> nil
    #
    # Possible options:
    #   - [TrueClass, FalseClass] binmode: output in binary mode
    #   - [String] chdir: change working directory
    #   - [String] stdin_data: standard input as string
    #   - [Numeric] timeout: maximum execution time in seconds
    #
    # @param [String, Array<String>] cmd command
    # @return [Array] stdout string, stderr string, process status
    def capture3t(*cmd)
      opts = cmd.last.is_a?(Hash) ? cmd.pop.dup : {}

      stdin_data = opts.delete(:stdin_data)
      binmode = opts.delete(:binmode)
      timeout = opts.delete(:timeout)
      raise ArgumentError if timeout.present? && timeout.negative?

      Open3.popen3(*cmd, opts) do |i, o, e, t|
        if binmode
          i.binmode
          o.binmode
          e.binmode
        end

        write_stdin(i, stdin_data)
        pwait(t, timeout)

        [o.read, e.read, t.value]
      end
    end

    # Open3t.capture2et captures the standard output and the standard error of a command within a given timeout.
    #
    # Process will return nil if timeout is reached.
    #   Open3t.capture3t[2].exitstatus #=> nil
    #
    # Possible options:
    #   - [TrueClass, FalseClass] binmode: output in binary mode
    #   - [String] chdir: change working directory
    #   - [String] stdin_data: standard input as string
    #   - [Numeric] timeout: maximum execution time in seconds
    #
    # @param [String, Array<String>] cmd command
    # @return [Array] stdout and stderr string, process status
    def capture2et(*cmd)
      opts = cmd.last.is_a?(Hash) ? cmd.pop.dup : {}

      stdin_data = opts.delete(:stdin_data)
      binmode = opts.delete(:binmode)
      timeout = opts.delete(:timeout)
      raise ArgumentError if timeout.present? && timeout.negative?

      # noinspection DuplicatedCode
      Open3.popen2e(*cmd, opts) do |i, oe, t|
        if binmode
          i.binmode
          oe.binmode
        end

        write_stdin(i, stdin_data)
        pwait(t, timeout)

        [oe.read, t.value]
      end
    end

    # Open3t.capture2t captures the standard output of a command within a given timeout.
    #
    # Process will return nil if timeout is reached.
    #   Open3t.capture3t[2].exitstatus #=> nil
    #
    # Possible options:
    #   - [TrueClass, FalseClass] binmode: output in binary mode
    #   - [String] chdir: change working directory
    #   - [String] stdin_data: standard input as string
    #   - [Numeric] timeout: maximum execution time in seconds
    #
    # @param [String, Array<String>] cmd command
    # @return [Array] stdout string, process status
    def capture2t(*cmd)
      opts = cmd.last.is_a?(Hash) ? cmd.pop.dup : {}

      stdin_data = opts.delete(:stdin_data)
      binmode = opts.delete(:binmode)
      timeout = opts.delete(:timeout)
      raise ArgumentError if timeout.present? && timeout.negative?

      # noinspection DuplicatedCode
      Open3.popen2(*cmd, opts) do |i, o, t|
        if binmode
          i.binmode
          o.binmode
        end

        write_stdin(i, stdin_data)
        pwait(t, timeout)

        [o.read, t.value]
      end
    end

    private

    # Writes data to stdin stream.
    #
    # @param [IO] stdin stdin stream
    # @param [String] data data to write
    def write_stdin(stdin, data)
      return if data.nil? || data.empty?

      if data.respond_to?(:readpartial)
        IO.copy_stream(data, stdin)
      else
        stdin.write(data)
      end
    rescue Errno::EPIPE
      # ignore
    ensure
      stdin.close
    end

    # Waits for a process until timeout is reached (terminated by SIGKILL).
    #
    # @param [Process::Waiter] process process to wait (spawned by popen*)
    # @param [Numeric] timeout seconds to wait; skip when timeout is nil
    def pwait(process, timeout)
      return unless timeout

      Thread.new do
        sleep timeout
        pkill(process.pid) if process.alive?
      end
    end

    # Kills a process by pid.
    #
    # @param [Integer] pid process ID
    def pkill(pid)
      Process.kill('KILL', pid)
    rescue Errno::ESRCH
      # ignore
    end
  end
end
