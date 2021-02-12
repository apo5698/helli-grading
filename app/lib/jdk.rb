# frozen_string_literal: true

# Java Development Kit tools.
module JDK
  # ':' on Unix/Mac, ';' on Windows.
  CLASSPATH_SEPARATOR = Gem.win_platform? ? ';' : ':'

  class << self
    # Compiles a Java file.
    #
    #   capture = JDK.javac("day1/student1/HelloWorld.java")
    #     capture.stdout        #=> ""
    #     capture.stderr        #=> ""
    #     capture.exitstatus    #=> 0
    #
    #   capture = JDK.javac("day1/student1/HelloWorldTest.java", libraries: ['junit'])
    #     capture.stdout        #=> ""
    #     capture.stderr        #=> ""
    #     capture.exitstatus    #=> 0
    #
    #   capture = JDK.javac("somewhere/else/Invalid.java")
    #     capture.stdout        #=> ""
    #     capture.stderr        #=> "Invalid.java:4: error: ';' expected\n..."
    #     capture.exitstatus    #=> 1
    def javac(filename, arguments = '', libraries: [])
      raise Errno::ENOENT, filename unless File.exist?(filename)

      arguments ||= ''
      libraries ||= []

      destination = '.'
      cp = classpath(destination, libraries)
      basename = File.basename(filename)

      cmd = ['javac', '-d', destination, '-cp', cp, basename, arguments].join(' ').strip
      capture = Open3.capture3(cmd, chdir: File.dirname(filename))

      Capture.new(cmd, capture)
    end

    # Runs a compiled Java file.
    #
    #   capture = JDK.java("day1/student1/HelloWorld.java")
    #     capture.stdout        #=> "No hello world"
    #     capture.stderr        #=> ""
    #     capture.exitstatus    #=> 0
    #
    #   capture = JDK.java("day7/student9/GradeCalculator.java", stdin: "abc")
    #     capture.stdout        #=> ""
    #     capture.stderr        #=> "Exception in thread "main" java.util.InputMismatchException\n..."
    #     capture.exitstatus    #=> 1
    #
    #   capture = JDK.java("day9/student17/Grades.java", args: "Jesse 98 78 89 70")
    #     capture.stdout        #=> "Jesse: 83.75"
    #     capture.stderr        #=> ""
    #     capture.exitstatus    #=> 0
    #
    #   capture = JDK.java("project2/student2/CoffeeShopTest.java", libraries: ['junit'])
    #     capture.stdout        #=> "Thanks for using JUnit! Support its development at ..."
    #     capture.stderr        #=> ""
    #     capture.exitstatus    #=> 0
    def java(filename, arguments = '', libraries: [], stdin: '', timeout: 5)
      raise Errno::ENOENT, filename unless File.exist?(filename)

      arguments ||= ''
      libraries ||= []
      stdin ||= ''
      timeout ||= 5

      basename = File.basename(filename)
      classfile = filename.sub(File.extname(filename), '.class')
      classname = File.basename(basename, '.*')

      destination = '.'
      cp = classpath(destination, libraries)

      # TODO: junit-standalone uses different command to launch unit tests
      cmd = if libraries.include?('junit')
              ['java', '-jar', Dependency.find_by(name: 'junit').path, '-cp', destination, '-c', classname, arguments]
            elsif !File.exist?(classfile)
              ['java', filename]
            else
              ['java', '-cp', cp, classname, arguments]
            end.join(' ')

      # Using Open3.capture3t to avoid running program that never terminates (e.g. infinite loop).
      capture = Open3t.capture3t(cmd, chdir: File.dirname(filename), stdin_data: stdin, timeout: timeout)

      Capture.new(cmd, capture)
    end

    # Runs checkstyle on a Java file.
    #
    #   capture = JDK.checkstyle("day1/student1/HelloWorld.java")
    #     capture.stdout        #=> "** Doing style check...\nStarting audit...\nAudit done.\n\n"
    #     capture.stderr        #=> ""
    #     capture.exitstatus    #=> 0
    #
    #   capture = JDK.checkstyle("somewhere/SomeWarnings.java")
    #     capture.stdout        #=> "** Doing style check...\nStarting audit...\n[WARN] ...\nAudit done.\n\n"
    #     capture.stderr        #=> ""
    #     capture.exitstatus    #=> 0
    def checkstyle(filename)
      cmd = [Dependency.find_by(name: 'cs-checkstyle').path, File.basename(filename)].join(' ')
      capture = Open3.capture3(cmd, chdir: File.dirname(filename))

      Capture.new(cmd, capture)
    end

    private

    def classpath(destination, libraries = [])
      cp = [destination]

      libraries.each do |lib|
        cp << "#{File.dirname(Dependency.find_by(name: lib).path)}/*"
      end

      cp.join(CLASSPATH_SEPARATOR)
    end
  end
end
