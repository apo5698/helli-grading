require 'open3'

module ProcessUtil
  # Execute a command with arguments. Returns a hash containing stdout, stderr,
  # and status.
  def self.exec(cmd, *args, stdin: '')
    args = args.map(&:to_s).reject(&:empty?).join(' ')
    cmd << ' ' << args
    stdout, stderr, status = Open3.capture3(cmd, stdin_data: stdin)
    cmd << " < #{stdin}" unless stdin.empty?
    puts(cmd)
    { stdout: stdout, stderr: stderr, status: status }
  end

  @junit = Dependency.path('junit')

  # Runs a compiled Java file (*.class).
  def self.java(file:, junit: false, args: '', stdin: '')
    file = file.sub('.java', '.class') if file.end_with?('.java')
    classname = File.basename(file).sub('.class', '')
    jar = junit ? "-jar #{@junit}" : ''
    output = exec('java',
                  jar, '-cp', File.dirname(file), junit ? '-c' : '', classname, args,
                  stdin: stdin)

    output[:stdout] = output[:stdout].gsub(file, File.basename(file))
    output[:stderr] = output[:stderr].gsub(file, File.basename(file))
    output
  end

  # Compiles a Java file (*.java).
  def self.javac(file:, junit: false, args: '')
    bin = File.dirname(file)
    cp = File.dirname(file)
    cp << ":#{@junit}" if junit
    output = exec('javac', '-d', bin, '-cp', cp, file, args)

    output[:stdout] = output[:stdout].gsub(file, File.basename(file))
    output[:stderr] = output[:stderr].gsub(file, File.basename(file))
    output
  end

  # Runs checkstyle on a Java file (*.java). checkstyle does not generate errors to stderr but stdout.
  def self.checkstyle(file)
    path = Dependency.path('cs-checkstyle')
    output = exec(path, file)

    output[:stdout] = output[:stdout].gsub(file, File.basename(file))
    output
  end
end
