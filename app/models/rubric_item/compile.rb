class RubricItem
  # Rubric for compiling a Java file.
  class Compile < RubricItem
    mattr_accessor :title, :usage, :required_fields, :default_set

    self.title = 'Compile'
    self.usage = 'Compiles a Java file.'
    self.required_fields = [:primary_file]
    self.default_set = [
      { action: :award, point: 1.0, criterion: :filename, feedback: @@feedbacks[:filename] },
      { action: :award, point: 1.0, criterion: :compile, feedback: @@feedbacks[:compile] }
    ]

    def run(primary_file, _, options)
      opts = options.deep_dup

      lib = opts[:lib].transform_values(&:to_b)

      captures = Helli::Java.javac(
        primary_file,
        junit: lib.delete(:enabled) && lib[:junit].to_b,
        args: opts[:args][:javac]
      )

      # only matches "* error(s)" at the end of stderr
      # match returns +nil+ if no match found
      error = captures[2].exitstatus.zero? ? 0 : captures[1].match(/\d+(?= errors?)/)[0] || 0

      [captures, error]
    end
  end
end
