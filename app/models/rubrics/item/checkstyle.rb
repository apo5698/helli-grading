# frozen_string_literal: true

module Rubrics
  module Item
    # Rubric for running checkstyle.
    class Checkstyle < Base
      class << self
        def default_criteria
          [
            { type: 'Rubrics::Criterion::MaximumPoint', action: :award, point: 5.0 },
            { type: 'Rubrics::Criterion::Checkstyle', action: :deduct_each, point: 1.0 }
          ]
        end

        def requirements
          [:filename]
        end
      end

      def run(filename, options)
        options.transform_values!(&:to_b)

        # checkstyle errors are in stdout, not stderr
        captures = JDK.checkstyle(filename)

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
            line.sub(Rails.root.join(filename).to_s, File.basename(filename))
          end.join("\n")
        end

        [captures, warnings.count]
      end
    end
  end
end
