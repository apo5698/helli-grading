class Rubric
  # Rubric for compiling a Java file.
  class Compile < Rubric
    mattr_accessor :title, :usage, :required_fields, :default_set

    self.title = 'Compile'
    self.usage = 'Compiles a Java file.'
    self.required_fields = [:primary_file]
    self.default_set = [
      { action: :award, point: 1.0, criterion: :filename, feedback: @@feedbacks[:filename] },
      { action: :award, point: 1.0, criterion: :compile, feedback: @@feedbacks[:compile] }
    ]

    def run(primary_file, _, options)
      lib = Wce.lib(options)

      process = Helli::Command::Java.javac(
        primary_file,
        junit: lib[:junit] || false,
        args: options[:args][:javac]
      )

      # only matches "* error(s)" at the end of stderr
      error = process.exitstatus.zero? ? 0 : process.stderr.match(/\d+(?= errors?)/)[0]

      [process, error]
    end
  end
end
