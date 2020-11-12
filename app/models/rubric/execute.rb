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

    # +test_file+ not used
    def run(primary_file, _, options)
      lib = Wce.lib(options)

      result = Helli::Process::Java.java(
        primary_file,
        junit: lib[:junit] || false,
        args: options[:args][:java],
        stdin: options[:stdin][:data]
      )
      stdout = result[:stdout]
      stderr = result[:stderr]
      exitcode = result[:exitcode]

      error = 0
      # runtime errors
      error += 1 if stderr.include?('Exception in thread')
      # rare situation
      error += 1 if stderr.include?('java.lang.NoClassDefFoundError')

      { exitcode: exitcode,
        stdout: stdout,
        stderr: stderr,
        error: error }
    end
  end
end
