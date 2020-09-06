require 'open3'

module ProcessUtil
  # Execute a command with arguments. Returns a hash containing stdout, stderr,
  # and status.
  def self.exec(cmd, *args, stdin: '')
    args = args.map(&:to_s).reject(&:empty?).join(' ')
    stdout, stderr, status = Open3.capture3(cmd + ' ' + args, stdin_data: stdin)
    puts("#{cmd} #{args} < #{stdin.split("\n").join(' ')}")
    { stdout: stdout, stderr: stderr, status: status }
  end

  @junit_bundle = "#{DependenciesUtil.path('junit4')}/*:#{DependenciesUtil.path('hamcrest-core')}/*"

  # Runs a compiled Java file (*.class).
  def self.java(file:, junit: false, args: '', stdin: '')
    file = file.sub('.java', '.class') if file.end_with?('.java')
    cp = File.dirname(file)
    cp += ":#{@junit_bundle}" if junit
    junit_pkg = junit ? 'org.junit.runner.JUnitCore' : ''
    classname = File.basename(file).sub('.class', '')
    exec('java', '-cp', cp, junit_pkg, classname, args, stdin: stdin)
  end

  # Compiles a Java file (*.java).
  def self.javac(file:, junit: false, args: '')
    dirname = File.dirname(file)
    cp = dirname
    cp += ":#{@junit_bundle}" if junit
    output = exec('javac', '-d', dirname, '-cp', cp, file, args)
    output[:stdout] = output[:stdout].gsub(file, File.basename(file))
    output[:stderr] = output[:stderr].gsub(file, File.basename(file))
    output
  end

  # Runs checkstyle on a Java file (*.java). checkstyle does not generate errors to stderr but stdout.
  def self.checkstyle(file)
    path = DependenciesUtil.path('cs-checkstyle')
    output = exec(path, file)
    output[:stdout] = output[:stdout].gsub(file, File.basename(file))
    output
  end
end
