# frozen_string_literal: true

require 'helli/errors'
require 'open3'

# Java-related commands.
module Helli::Java
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

  class << self
    # Create directories for nested structure.
    def setup(working_directory)
      %w[bin src test test-files].map { |dir| working_directory + '/' + dir }.each { |dir| FileUtils.mkdir_p(dir) }
    end

    # Compiles a java file.
    #
    #   p = Helli::Java.javac("day1/student1/HelloWorld.java")
    #     p[0]              #=> ""
    #     p[1]              #=> ""
    #     p[2].exitstatus   #=> 0
    #
    #   p = Helli::Java.javac("day1/student1/HelloWorldTest.java", junit: true)
    #     p[0]              #=> ""
    #     p[1]              #=> ""
    #     p[2].exitstatus   #=> 0
    #
    #   p = Helli::Java.javac("somewhere/else/Invalid.java")
    #     p[0]              #=> ""
    #     p[1]              #=> "Invalid.java:4: error: ';' expected\n..."
    #     p[2].exitstatus   #=> 1
    def javac(filename, args: '', junit: false)
      raise Helli::FileNotFound, filename unless File.exist?(filename)
      raise Helli::UnsupportedFileType, File.extname(filename) unless filename.end_with?(JAVA_FILE_EXTENSION)

      wd = File.dirname(filename)
      destination = '.'
      classpath = [destination.dup]
      if junit
        @junit ||= Helli::Dependency.find_by(name: 'junit').path
        classpath << "#{File.dirname(@junit)}/*"
      end
      classpath = classpath.join(CLASSPATH_SEPARATOR)
      filename = File.basename(filename)

      cmd = ['javac', '-d', destination, '-cp', classpath, filename, args].join(' ')
      Open3.capture3(cmd, chdir: wd)
    end

    # Runs a compiled java file.
    #
    #   p = Helli::Java.java("day1/student1/HelloWorld.java")
    #     p[0]              #=> "No hello world"
    #     p[1]              #=> ""
    #     p[2].exitstatus   #=> 0
    #
    #   p = Helli::Java.java("day7/student9/GradeCalculator.java", stdin: "abc")
    #     p[0]              #=> ""
    #     p[1]              #=> "Exception in thread "main" java.util.InputMismatchException\n..."
    #     p[2].exitstatus   #=> 1
    #
    #   p = Helli::Java.java("day9/student17/Grades.java", args: "Jesse 98 78 89 70")
    #     p[0]              #=> "Jesse: 83.75"
    #     p[1]              #=> ""
    #     p[2].exitstatus   #=> 0
    #
    #   p = Helli::Java.java("project2/student2/CoffeeShopTest.java", junit: true)
    #     p[0]              #=> "Thanks for using JUnit! Support its development at ..."
    #     p[1]              #=> ""
    #     p[2].exitstatus   #=> 0
    def java(filename, args: '', stdin: '', junit: false, timeout: 5)
      raise Helli::FileNotFound, filename unless File.exist?(filename)

      unless [JAVA_FILE_EXTENSION, CLASS_FILE_EXTENSION].include?(File.extname(filename))
        raise Helli::UnsupportedFileType, File.extname(filename)
      end

      classfile = filename.sub(File.extname(filename), CLASS_FILE_EXTENSION)
      raise Helli::FileNotFound, classfile unless File.exist?(classfile)

      wd = File.dirname(filename)
      classpath = '.'
      classname = File.basename(classfile).delete_suffix(CLASS_FILE_EXTENSION)

      cmd = if junit
              ['java', '-jar', Helli::Dependency.find_by(name: 'junit').path, '-cp', classpath, '-c', classname, args].join(' ')
            else
              ['java', '-cp', classpath, classname, args].join(' ')
            end

      # Using Helli::Open3.capture3t to avoid running program that never terminates (e.g. infinite loop).
      Helli::Open3.capture3t(cmd, chdir: wd, stdin_data: stdin, timeout: timeout)
    end

    # Runs checkstyle on a java file.
    #
    #   p = Helli::Java.checkstyle("day1/student1/HelloWorld.java")
    #     p[0]              #=> "** Doing style check...\nStarting audit...\nAudit done.\n\n"
    #     p[1]              #=> ""
    #     p[2].exitstatus   #=> 0
    #
    #   p = Helli::Java.checkstyle("somewhere/SomeWarnings.java")
    #     p[0]              #=> "** Doing style check...\nStarting audit...\n[WARN] ...\nAudit done.\n\n"
    #     p[1]              #=> ""
    #     p[2].exitstatus   #=> 0
    def checkstyle(filename)
      cmd = [Helli::Dependency.find_by(name: 'cs-checkstyle').path, File.basename(filename)].join(' ')
      Open3.capture3(cmd, chdir: File.dirname(filename))
    end
  end
end
