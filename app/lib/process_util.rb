require 'open3'

module ProcessUtil
  # Execute a command with arguments. Returns a hash containing stdout, stderr,
  # and status.
  def self.exec(cmd, *args)
    args = args.map(&:to_s).reject(&:empty?).map { |e| "'#{e}'" }.join(' ')
    stdout, stderr, status = Open3.capture3(cmd + ' ' + args)
    { stdout: stdout, stderr: stderr, status: status }
  end

  @junit_bundle = "#{DependenciesUtil.path('junit4')}/*:#{DependenciesUtil.path('hamcrest-core')}/*"

  # Runs a compiled Java file (*.class).
  def self.java(file:, junit: false, opt: [])
    file = file.sub('.java', '.class') if file.end_with?('.java')
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

  # Runs checkstyle on a Java file (*.java). checkstyle does not generate errors to stderr but stdout.
  def self.checkstyle(file)
    path = DependenciesUtil.path('cs-checkstyle', '').join('checkstyle').to_s
    output = exec(path, file)
    output[:stdout] = output[:stdout].gsub(file, File.basename(file))
    output
  end
end
