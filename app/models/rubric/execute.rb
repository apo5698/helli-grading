class Rubric
  # Rubric for executing a Java file.
  class Execute < Rubric
    mattr_accessor :title, :usage, :required_fields, :default_set

    self.title = 'Execute'
    self.usage = 'Executes a Java file.'
    self.required_fields = [:primary_file]
    self.default_set = [
      { action: :award, point: 1.0, criterion: :classname, feedback: @@feedbacks[:classname] },
      { action: :award, point: 2.0, criterion: :execute, feedback: @@feedbacks[:execute] }
    ]

    def run(primary_file, _, options)
      lib = options[:lib].transform_values(&:to_b)

      process = Helli::Command::Java.java(
        primary_file,
        junit: lib.delete(:enabled) && lib[:junit].to_b,
        args: options[:args].delete(:enabled).to_b ? options[:args][:java] : '',
        stdin: options[:stdin].delete(:enabled).to_b ? options[:stdin][:data] : ''
      )
      stderr = process.stderr

      if options[:create].delete(:enabled).to_b
        created_file = options[:create][:filename]
        Dir.chdir(File.dirname(primary_file)) do
          process.other = if File.exist?(created_file)
                            "[#{created_file}]\n#{File.read(created_file)}"
                          else
                            "#{created_file} not created"
                          end
        end
      end

      error = 0
      # runtime errors
      error += 1 if stderr.include?('Exception in thread')
      # rare situation
      error += 1 if stderr.include?('java.lang.NoClassDefFoundError')

      [process, error]
    end
  end
end
