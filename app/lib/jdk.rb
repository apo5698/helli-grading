# frozen_string_literal: true

# Java Development Kit tools.
module JDK
  # ':' on Unix/Mac, ';' on Windows.
  CLASSPATH_SEPARATOR = Gem.win_platform? ? ';' : ':'

  class << self
    # Compiles a Java file.
    #
    #   p = JDK.javac("day1/student1/HelloWorld.java")
    #     p[0]              #=> ""
    #     p[1]              #=> ""
    #     p[2].exitstatus   #=> 0
    #
    #   p = JDK.javac("day1/student1/HelloWorldTest.java", libraries: ['junit'])
    #     p[0]              #=> ""
    #     p[1]              #=> ""
    #     p[2].exitstatus   #=> 0
    #
    #   p = JDK.javac("somewhere/else/Invalid.java")
    #     p[0]              #=> ""
    #     p[1]              #=> "Invalid.java:4: error: ';' expected\n..."
    #     p[2].exitstatus   #=> 1
    def javac(filename, arguments = '', libraries: [])
      raise Errno::ENOENT, filename unless File.exist?(filename)

      arguments ||= ''
      libraries ||= []

      destination = '.'
      cp = classpath(destination, libraries)
      basename = File.basename(filename)

      cmd = ['javac', '-d', destination, '-cp', cp, basename, arguments].join(' ').strip
      Open3.capture3(cmd, chdir: File.dirname(filename))
    end

    # Runs a compiled Java file.
    #
    #   p = JDK.java("day1/student1/HelloWorld.java")
    #     p[0]              #=> "No hello world"
    #     p[1]              #=> ""
    #     p[2].exitstatus   #=> 0
    #
    #   p = JDK.java("day7/student9/GradeCalculator.java", stdin: "abc")
    #     p[0]              #=> ""
    #     p[1]              #=> "Exception in thread "main" java.util.InputMismatchException\n..."
    #     p[2].exitstatus   #=> 1
    #
    #   p = JDK.java("day9/student17/Grades.java", args: "Jesse 98 78 89 70")
    #     p[0]              #=> "Jesse: 83.75"
    #     p[1]              #=> ""
    #     p[2].exitstatus   #=> 0
    #
    #   p = JDK.java("project2/student2/CoffeeShopTest.java", libraries: ['junit'])
    #     p[0]              #=> "Thanks for using JUnit! Support its development at ..."
    #     p[1]              #=> ""
    #     p[2].exitstatus   #=> 0
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
      Open3t.capture3t(cmd, chdir: File.dirname(filename), stdin_data: stdin, timeout: timeout)
    end

    # Runs checkstyle on a Java file.
    #
    #   p = JDK.checkstyle("day1/student1/HelloWorld.java")
    #     p[0]              #=> "** Doing style check...\nStarting audit...\nAudit done.\n\n"
    #     p[1]              #=> ""
    #     p[2].exitstatus   #=> 0
    #
    #   p = JDK.checkstyle("somewhere/SomeWarnings.java")
    #     p[0]              #=> "** Doing style check...\nStarting audit...\n[WARN] ...\nAudit done.\n\n"
    #     p[1]              #=> ""
    #     p[2].exitstatus   #=> 0
    def checkstyle(filename)
      cmd = [Dependency.find_by(name: 'cs-checkstyle').path, File.basename(filename)].join(' ')
      Open3.capture3(cmd, chdir: File.dirname(filename))
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
