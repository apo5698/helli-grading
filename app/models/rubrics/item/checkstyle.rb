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
        config = options[:config]
        capture = JDK.checkstyle(filename)

        # checkstyle errors are in stdout, not stderr
        # warnings begin with [WARN]
        warnings = capture.stdout.split("\n").grep(/^\[WARN\]\s.+$/)

        # Keep warnings of presented checks only
        config.reduce([]) { |arr, rule| arr + warnings.grep(/(?<=.\[).*#{rule}.*(?=\])/) } if warnings.present?

        # Keep filename only
        # macOS prefixes '/private' for tmpdir, but Heroku uses Linux so it should be fine.
        capture.stdout = warnings.map { |line| line.sub(filename, File.basename(filename)) }.join("\n")

        [capture, warnings]
      end
    end
  end
end
