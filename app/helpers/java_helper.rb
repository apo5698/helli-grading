require 'open3'

module JavaHelper
  # Execute a command with arguments. Returns a hash containing stdout, stderr,
  # and status.
  def self.exec(cmd, *args)
    args = args.map(&:to_s).reject(&:empty?).map { |e| "'#{e}'" }.join(' ')
    stdout, stderr, status = Open3.capture3(cmd + ' ' + args)
    { stdout: stdout, stderr: stderr, status: status }
  end

  @junit_bundle = "#{ConfigHelper.lib_path('junit4')}/*:#{ConfigHelper.lib_path('hamcrest-core')}/*"

  # Runs a compiled Java file (*.class).
  def self.java(file:, junit: false, opt: [])
    cp = File.dirname(file)
    cp += ":#{@junit_bundle}" if junit
    junit_pkg = junit ? 'org.junit.runner.JUnitCore' : ''
    classname = File.basename(file).sub('.class', '')
    exec('java', '-cp', cp, junit_pkg, classname, opt.join(' '))
  end

  # Compiles a Java file (*.java).
  def self.javac(file:, junit: false, opt: [])
    dirname = File.dirname(file)
    cp = dirname
    cp += ":#{@junit_bundle}" if junit
    output = exec('javac', '-d', dirname, '-cp', cp, file, opt.join(' '))
    output[:stdout] = output[:stdout].gsub(file, File.basename(file))
    output[:stderr] = output[:stderr].gsub(file, File.basename(file))
    output
  end

  # Runs checkstyle on a Java file (*.java).
  def self.checkstyle(file)
    path = ConfigHelper.path('checkstyle')
    exec(path, file)
  end
end
