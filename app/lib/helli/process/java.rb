require 'helli/error'
require 'open3'

module Helli
  module Process
    # *Java*-related commands.
    module Java
      FILENAME_REGEXP_STR = '[A-Z]\w*.java'.freeze
      FILENAME_REGEXP = /#{FILENAME_REGEXP_STR}/.freeze

      @checkstyle = Dependency.path('cs-checkstyle')
      @junit = Dependency.path('junit')

      class << self
        # Runs checkstyle on a java file.
        #
        #   Command::Java.checkstyle('HelloWorld.java')
        #     #=> { stdout: '** Doing style check...\nStarting audit...\nAudit done.\n\n'
        #           stderr: '',
        #           exitcode: 0 }
        #
        # Warnings are outputted to +stdout+ instead of +stderr+.
        def checkstyle(file)
          stdout, stderr, status = Open3.capture3(@checkstyle, file)
          stdout.gsub!(file, File.basename(file)) if Rails.env.production?
          { stdout: stdout, stderr: stderr, exitcode: status.exitstatus }
        end

        # Runs a compiled java file.
        #
        #   Command::Java.java('HelloWorld.java')
        #     #=> { stdout: 'No hello world',
        #           stderr: '',
        #           exitcode: 0 }
        #
        #   Command::Java.java('GradeCalculator.class', stdin: 'abc')
        #     #=> { stdout: '',
        #           stderr: 'Exception in thread "main" java.util.InputMismatchException\n...',
        #           exitcode: 1 }
        #
        #   Command::Java.java('Grades.java', args: '"Jesse Jones" 98 78 89 70')
        #     #=> { stdout: 'Jesse Jones: 83.75',
        #           stderr: '',
        #           exitcode: 0 }
        #
        #   Command::Java.java('CoffeeShopTest.java', junit: true)
        #     #=> { stdout: 'Thanks for using JUnit! Support its development at ...',
        #           stderr: '',
        #           exitcode: 0 }
        def java(file, args: '', stdin: '', junit: false, directory: nil)
          raise UnsupportedFileError, 'java: unsupported file type' unless %w[.java .class].include?(File.extname(file))

          class_file = file.sub('.java', '.class')
          raise FileNotFoundError, class_file unless File.exist?(class_file)

          dir = directory || File.dirname(file)
          class_name = File.basename(class_file).sub('.class', '')
          cmd = if junit
                  "java -jar #{@junit} -cp #{dir} -c #{class_name} #{args}"
                else
                  "java -cp #{dir} #{class_name} #{args}"
                end

          stdout, stderr, status = Open3.capture3(cmd, stdin_data: stdin)

          # hide full file path in production
          if Rails.env.production?
            stdout.gsub!(file, File.basename(file))
            stderr.gsub!(file, File.basename(file))
          end

          { stdout: stdout, stderr: stderr, exitcode: status.exitstatus }
        end

        # Compiles a java file.
        #
        #   Command::Java.javac('HelloWorld.java')
        #     #=> { stdout: '',
        #           stderr: '',
        #           exitcode: 0 }
        #
        #   Command::Java.javac('GradeCalculator.java')
        #     #=> { stdout: '',
        #           stderr: 'ABC.java:4: error: ';' expected\n...',
        #           exitcode: 1 }
        def javac(file, args: '', junit: false, directory: nil)
          raise UnsupportedFileError, 'javac: unsupported file type' unless file.end_with?('.java')

          bin = directory || File.dirname(file)
          dir = directory || File.dirname(file)
          dir << ":#{@junit}/*" if junit
          cmd = "javac -d #{bin} -cp #{dir} #{file} #{args}"

          stdout, stderr, status = Open3.capture3(cmd)

          if Rails.env.production?
            stdout.gsub!(file, File.basename(file))
            stderr.gsub!(file, File.basename(file))
          end

          { stdout: stdout, stderr: stderr, exitcode: status.exitstatus }
        end
      end
    end
  end
end
