class Rubric
  # Rubric for running checkstyle.
  class Checkstyle < Rubric
    mattr_accessor :title, :usage, :required_fields, :default_set

    self.title = 'Checkstyle'
    self.usage = 'This step runs the checkstyle script.'
    self.required_fields = [:primary_file]
    self.default_set = [
      { action: :award, point: 5.0, criterion: :max_point, feedback: @@feedbacks[:max_point] },
      { action: :deduct_each, point: 1.0, criterion: :checkstyle_warning, feedback: @@feedbacks[:checkstyle_warning] }
    ]

    RULES = {
      'EmptyLineSeparator': 'Definition is not separated from previous statement',
      'FileTabCharacter': 'Line contains a tab character',
      'Indentation': 'Incorrect indentation level',
      '(JavadocVariable)|MissingJavadoc(Type|Method)': 'Missing Javadoc comment',
      'LineLength': 'Line is longer than 100 characters',
      'LocalVariableName': 'Local variable name must match pattern ^[a-z][a-zA-Z0-9]*$',
      'MagicNumber': 'Contains magic numbers',
      'UnusedImports': 'Contains Unused imports',
      'WhitespaceAround': 'Operators/operands are not preceded/followed with whitespace'
    }.freeze

    # +test_file+ not used
    def run(primary_file, _, options)
      opt = options[:checkstyle].transform_values { |v| v.to_i == 1 }
      raise StandardError, 'No checkstyle rule selected.' if opt.values.all?(&:!) # (&:!) means false

      # checkstyle errors are in stdout, not stderr
      result = Helli::Process::Java.checkstyle(primary_file)
      stdout = result[:stdout]
      exitcode = result[:exitcode]

      filename = File.basename(primary_file)
      # remove path (absolute)
      stdout.gsub!(Rails.root.join(primary_file).to_s, filename)

      # warnings begin with [WARN]
      warnings = stdout.split("\n").grep(/^\[WARN\]\s.+$/)
      # invert match: remove unselected rules and keep those selected
      if warnings.count.positive?
        opt.each { |rule, enabled| warnings = warnings.grep_v(/\[#{rule}\]$/) unless enabled }
      end

      # regard warnings as stderr, although they are in stdout
      stderr = warnings.join("\n")
      error = warnings.count

      { exitcode: exitcode,
        stdout: '',
        stderr: stderr,
        error: error }
    end
  end
end
