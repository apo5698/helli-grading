require 'open3'

# Creates child processes to run commands. Returns a hash:
#
#    { stdout: ..., stderr: ..., exitcode: ... }
#
# +stdout+ and +stderr+ will be empty string instead of +nil+, if nothing happened.
module Command
  # The stupid content tracker, as described in man page ( ͡° ͜ʖ ͡°)
  module Git
    # Clone a repository into a new directory.
    #   git clone <repository> <path>
    def self.clone(repository, path)
      Open3.capture3("git clone #{repository} #{path}")
    end

    # Fetch from and integrate with another repository or a local branch
    #   git -C <git-working-directory> pull
    def self.pull(path)
      Open3.capture3("git -C #{path} pull")
    end

    # Initialize, update or inspect git submodules.
    module Submodule
      # Add the given repository as a submodule at the given path.
      #   git submodule add --force <repository> <path>
      def self.add(repository, path, force: true)
        Open3.capture3("git submodule add #{force ? '--force' : ''} #{repository} #{path}")
      end

      # Recurse into the registered submodules, and update any nested submodules within.
      #   git submodule update --init --recursive
      def self.update(init: true, recursive: true)
        Open3.capture3("git submodule update #{init ? '--init' : ''} #{recursive ? '--recursive' : ''}")
      end
    end
  end

  # *Java*-related commands.
  module Java
    # The filename pattern for java files.
    FILENAME_PATTERN = /^[A-Z]\w*$/.freeze

    # Raised when error occurs during compilation. Only use this if compilation is aborted.
    class CompileError < StandardError
      def initialize(file = 'file')
        super("#{file} cannot be compiled")
      end
    end

    @checkstyle = Dependency.path('cs-checkstyle')
    @junit = Dependency.path('junit')

    # Runs checkstyle on a java file.
    #
    #   Command::Java.checkstyle('HelloWorld.java')
    #     #=> { stdout: '** Doing style check...\nStarting audit...\nAudit done.\n\n'
    #           stderr: '',
    #           exitcode: 0 }
    #
    # Warnings are outputted to +stdout+ instead of +stderr+.
    def self.checkstyle(file)
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
    def self.java(file, args: '', stdin: '', junit: false, directory: nil)
      raise UnsupportedFileError, 'unsupported file type' unless %w[.java .class].include?(File.extname(file))

      class_file = file.sub('.java', '.class')
      raise CompileError, file unless File.exist?(class_file)

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
    def self.javac(file, args: '', junit: false, directory: nil)
      raise UnsupportedFileError, 'unsupported file type' unless file.end_with?('.java')

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
