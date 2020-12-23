class RubricItem
  # Rubric for running checkstyle.
  class Checkstyle < RubricItem
    mattr_accessor :title, :usage, :required_fields, :default_set

    self.title = 'Checkstyle'
    self.usage = 'This step runs the checkstyle script.'
    self.required_fields = [:primary_file]
    self.default_set = [
      { action: :award, point: 5.0, criterion: :max_point, feedback: @@feedbacks[:max_point] },
      { action: :deduct_each, point: 1.0, criterion: :checkstyle_warning, feedback: @@feedbacks[:checkstyle_warning] }
    ]

    # noinspection SpellCheckingInspection
    RULES = {
      'Javadoc': 'Missing Javadoc comment',
      'MagicNumber': 'Contains magic numbers'
    }.freeze

    def run(primary_file, _, options)
      options.transform_values!(&:to_b)

      # checkstyle errors are in stdout, not stderr
      captures = Helli::Java.checkstyle(primary_file)

      # warnings begin with [WARN]
      warnings = captures[0].split("\n").grep(/^\[WARN\]\s.+$/)

      # invert match: remove unselected rules and keep those selected
      if warnings.count.positive?
        selected_rules = options.reject { |_, enabled| enabled }.keys
        selected_rules.each { |rule| warnings = warnings.grep_v(/(?<=.\[).*#{rule}.*(?=\])/) }
      end

      # hide full path in production
      if Rails.env.production?
        captures[0] = warnings.map do |line|
          line.sub(Rails.root.join(primary_file).to_s, File.basename(primary_file))
        end.join("\n")
      end

      [captures, warnings.count]
    end
  end
end
