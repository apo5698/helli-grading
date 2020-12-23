class RubricItem
  # Rubric for executing a Java file.
  class Execute < RubricItem
    mattr_accessor :title, :usage, :required_fields, :default_set

    self.title = 'Execute'
    self.usage = 'Executes a Java file.'
    self.required_fields = [:primary_file]
    self.default_set = [
      { action: :award, point: 1.0, criterion: :classname, feedback: @@feedbacks[:classname] },
      { action: :award, point: 2.0, criterion: :execute, feedback: @@feedbacks[:execute] }
    ]

    def run(primary_file, _, options)
      opt = options.deep_dup

      lib = opt[:lib].transform_values(&:to_b)

      captures = Helli::Java.java(
        primary_file,
        junit: lib.delete(:enabled) && lib[:junit].to_b,
        args: opt[:args].delete(:enabled).to_b ? opt[:args][:java] : '',
        stdin: opt[:stdin].delete(:enabled).to_b ? opt[:stdin][:data] : '',
        timeout: opt[:timeout].delete(:enabled).to_b ? opt[:timeout][:timeout].to_i : 5
      )
      stderr = captures[1]

      if opt[:create].delete(:enabled).to_b
        c_filename = opt[:create][:filename]
        c_path = File.join(File.dirname(primary_file), c_filename)
        captures[0] << if File.exist?(c_path)
                         "\n[#{c_filename}]\n#{File.read(c_path)}"
                       else
                         "\n#{c_filename} not created"
                       end
      end

      error = 0
      # runtime errors
      error += 1 if stderr.include?('Exception in thread')
      # rare situation
      error += 1 if stderr.include?('java.lang.NoClassDefFoundError')

      [captures, error]
    end
  end
end
