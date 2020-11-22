# frozen_string_literal: true

require 'helli/error'
require 'open3'

# Java-related commands.
module Helli::Command::Java
  # The string representation of FILENAME_REGEXP.
  FILENAME_REGEXP_STR = '[A-Z]\w*.java'
  # Used to validate a Java filename.
  FILENAME_REGEXP = /#{FILENAME_REGEXP_STR}/.freeze
  # ':' on Unix/Mac, ';' on Windows.
  CLASSPATH_SEPARATOR = Gem.win_platform? ? ';' : ':'
  # Java file extension.
  JAVA_FILE_EXTENSION = '.java'
  # Class file extension.
  CLASS_FILE_EXTENSION = '.class'

  @checkstyle = Dependency.path('cs-checkstyle')
  @junit = Dependency.path('junit')

  class << self
    # Create directories for nested structure.
    def setup(working_directory)
      %w[bin src test test-files].map { |dir| working_directory + '/' + dir }.each { |dir| FileUtils.mkdir_p(dir) }
    end

    # Compiles a java file.
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
    #     p.working_directory #=> "somewhere/else"
    #     p.command           #=> "javac -d . -cp . Invalid.java"
    #     p.stdin             #=> ""
    #     p.stdout            #=> ""
    #     p.stderr            #=> "Invalid.java:4: error: ';' expected\n..."
    #     p.exitstatus        #=> 1
    def javac(path, args: '', junit: false)
      raise UnsupportedFileError, 'javac: unsupported file type' unless path.end_with?(JAVA_FILE_EXTENSION)

      wd = File.dirname(path)
      destination = '.'
      classpath = [destination.dup]
      classpath << "#{File.dirname(@junit)}/*" if junit
      classpath = classpath.join(CLASSPATH_SEPARATOR)

      filename = File.basename(path)

      Helli::Process.new(wd).open('javac', '-d', destination, '-cp', classpath, filename, args)
    end

    # Runs a compiled java file.
    #
    #   p = Helli::Command::Java.java('day1/student1/HelloWorld.java')
    #     p.working_directory #=> "day1/student1"
    #     p.command           #=> "java -cp . HelloWorld"
    #     p.stdin             #=> ""
    #     p.stdout            #=> "No hello world"
    #     p.stderr            #=> ""
    #     p.exitstatus        #=> 0
    #
    #   p = Helli::Command::Java.java('day7/student9/GradeCalculator.java', stdin: 'abc')
    #     p.working_directory #=> "day7/student9"
    #     p.command           #=> "java -cp . GradeCalculator"
    #     p.stdin             #=> "abc"
    #     p.stdout            #=> ""
    #     p.stderr            #=> "Exception in thread "main" java.util.InputMismatchException\n..."
    #     p.exitstatus        #=> 1
    #
    #   p = Helli::Command::Java.java('day9/student17/Grades.java', args: 'Jesse 98 78 89 70')
    #     p.working_directory #=> "day9/student17"
    #     p.command           #=> "javac -cp . Grades Jesse 98 78 89 70"
    #     p.stdin             #=> ""
    #     p.stdout            #=> "Jesse: 83.75"
    #     p.stderr            #=> ""
    #     p.exitstatus        #=> 0
    #
    #   p = Helli::Command::Java.java('project2/student2/CoffeeShopTest.java', junit: true)
    #     p.working_directory #=> "project2/student2"
    #     p.command           #=> "java -jar junit-some-version.jar -cp . -c CoffeeShopTest"
    #     p.stdin             #=> ""
    #     p.stdout            #=> "Thanks for using JUnit! Support its development at ..."
    #     p.stderr            #=> ""
    #     p.exitstatus        #=> 0
    def java(path, args: '', stdin: '', junit: false)
      unless [JAVA_FILE_EXTENSION, CLASS_FILE_EXTENSION].include?(File.extname(path))
        raise UnsupportedFileError, 'java: unsupported file type'
      end

      wd = File.dirname(path)
      classpath = '.'
      classname = File.basename(path).delete_suffix(JAVA_FILE_EXTENSION).delete_suffix(CLASS_FILE_EXTENSION)

      cmd = if junit
              ['java', '-jar', @junit, '-cp', classpath, '-c', classname, args]
            else
              ['java', '-cp', classpath, classname, args]
            end

      Helli::Process.new(wd).open(cmd, stdin: stdin)
    end

    # Runs checkstyle on a java file.
    #
    #   p = Helli::Command::Java.checkstyle('day1/student1/HelloWorld.java')
    #     p.working_directory #=> "day1/student1"
    #     p.command           #=> "checkstyle day1/student1/HelloWorld.java"
    #     p.stdin             #=> ""
    #     p.stdout            #=> "** Doing style check...\nStarting audit...\nAudit done.\n\n"
    #     p.stderr            #=> ""
    #     p.exitstatus        #=> 0
    #
    #   p = Helli::Command::Java.checkstyle('somewhere/SomeWarnings.java')
    #     p.working_directory #=> "somewhere"
    #     p.command           #=> "checkstyle SomeWarnings.java"
    #     p.stdin             #=> ""
    #     p.stdout            #=> "** Doing style check...\nStarting audit...\n[WARN] ...\nAudit done.\n\n"
    #     p.stderr            #=> ""
    #     p.exitstatus        #=> 0
    def checkstyle(path)
      Helli::Process.new(File.dirname(path)).open(@checkstyle, File.basename(path))
    end
  end
end
