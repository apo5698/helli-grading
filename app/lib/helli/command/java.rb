# frozen_string_literal: true

require 'helli/error'
require 'open3'

# Java-related commands.
module Helli::Command::Java
  FILENAME_REGEXP_STR = '[A-Z]\w*.java'
  FILENAME_REGEXP = /#{FILENAME_REGEXP_STR}/.freeze
  # ':' on Unix/Mac, ';' on Windows.
  CLASSPATH_SEPARATOR = Gem.win_platform? ? ';' : ':'
  JAVAC_FILENAME_EXTENSION = '.class'
  JAVA_FILENAME_EXTENSION = '.java'
  NESTED_DIRECTORIES = %w[bin src test test-files].freeze

  @checkstyle = Dependency.path('cs-checkstyle')
  @junit = Dependency.path('junit')

  class << self
    # Create directories for nested structure.
    def setup(working_directory)
      NESTED_DIRECTORIES.map { |dir| working_directory + '/' + dir }.each { |dir| FileUtils.mkdir_p(dir) }
    end

    # Compiles a java file and then returns a Helli::Process.
    #
    #   p = Helli::Command::Java.javac('day1/student1/HelloWorld.java')
    #     p.working_directory #=> "day1/student"
    #     p.command           #=> "javac -d . -cp . HelloWorld.java"
    #     p.stdin             #=> ""
    #     p.stdout            #=> ""
    #     p.stderr            #=> ""
    #     p.exitstatus        #=> 0
    #
    #   p = Helli::Command::Java.javac('day1/student1/HelloWorldTest.java', junit: true)
    #     p.working_directory #=> "day1/student"
    #     p.command           #=> "javac -d . -cp .:junit-some-version.jar HelloWorldTest.java"
    #     p.stdin             #=> ""
    #     p.stdout            #=> ""
    #     p.stderr            #=> ""
    #     p.exitstatus        #=> 0
    #
    #   p = Helli::Command::Java.javac('somewhere/else/Invalid.java')
    #     p.working_directory #=> 'somewhere/else'
    #     p.command           #=> 'javac -d . -cp . Invalid.java'
    #     p.stdin             #=> ""
    #     p.stdout            #=> ""
    #     p.stderr            #=> "Invalid.java:4: error: ';' expected\n..."
    #     p.exitstatus        #=> 1
    def javac(path, args: '', junit: false)
      raise UnsupportedFileError, 'javac: unsupported file type' unless path.end_with?('.java')

      wd = File.dirname(path)

      destination = '.'

      classpath = [destination.dup]
      classpath << "#{File.dirname(@junit)}/*" if junit
      classpath = classpath.join(CLASSPATH_SEPARATOR)

      filename = File.basename(path)

      Helli::Process.new(wd).open('javac', '-d', destination, '-cp', classpath, filename, args)
    end

    # Runs a compiled java file and then returns a Helli::Process.
    #
    #   p = Helli::Command::Java.java('HelloWorld.java')
    #     #=> { stdout: 'No hello world',
    #           stderr: '',
    #           exitcode: 0 }
    #
    #   p = Helli::Command::Java.java('GradeCalculator.class', stdin: 'abc')
    #     #=> { stdout: '',
    #           stderr: 'Exception in thread "main" java.util.InputMismatchException\n...',
    #           exitcode: 1 }
    #
    #   p = Helli::Command::Java.java('Grades.java', args: '"Jesse Jones" 98 78 89 70')
    #     #=> { stdout: 'Jesse Jones: 83.75',
    #           stderr: '',
    #           exitcode: 0 }
    #
    #   p = Helli::Command::Java.java('CoffeeShopTest.java', junit: true)
    #     p.working_directory #=> 'day1/student'
    #     p.command           #=> ''
    #     p.stdin             #=> ''
    #     p.stdout            #=> 'Thanks for using JUnit! Support its development at ...'
    #     p.stderr            #=> ''
    #     p.exitstatus        #=> 0
    def java(path, args: '', stdin: '', junit: false)
      raise UnsupportedFileError, 'java: unsupported file type' unless %w[.java .class].include?(File.extname(path))

      wd = File.dirname(path)

      classpath = '.'
      classname = File.basename(path).delete_suffix('.java')

      cmd = if junit
              ['java', '-jar', @junit, '-cp', classpath, '-c', classname, args]
            else
              ['java', '-cp', classpath, classname, args]
            end

      Helli::Process.new(wd).open(cmd, stdin: stdin)
    end

    # Runs checkstyle on a java file.
    #
    #   p = Helli::Command::Java.checkstyle('HelloWorld.java')
    #     #=> { stdout: '** Doing style check...\nStarting audit...\nAudit done.\n\n'
    #           stderr: '',
    #           exitcode: 0 }
    #
    # Warnings are outputted to +stdout+ instead of +stderr+.
    def checkstyle(file)
      stdout, stderr, status = Open3.capture3(@checkstyle, file)
      stdout.gsub!(file, File.basename(file)) if Rails.env.production?
      { stdout: stdout, stderr: stderr, exitstatus: status.exitstatus }
    end
  end
end
