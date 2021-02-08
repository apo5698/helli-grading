# frozen_string_literal: true

module Rubrics
  module Item
    # Rubric for executing a Java file.
    class Execute < Base
      class << self
        def default_criteria
          [
            { type: 'Rubrics::Criterion::Classname', action: :award, point: 1.0 },
            { type: 'Rubrics::Criterion::Execute', action: :award, point: 4.0 }
          ]
        end

        def requirements
          [:filename]
        end
      end

      def run(filename, options)
        stdin = options[:stdin]

        captures = JDK.java(
          filename,
          options[:arguments],
          libraries: options[:libraries],
          stdin: stdin,
          timeout: options[:timeout]
        )

        stdout = captures[0]
        stderr = captures[1]
        exitstatus = captures[2].exitstatus

        error = []

        error << I18n.t('rubrics.item.errors.execute.stderr') if stderr.present?
        error << I18n.t('rubrics.item.errors.execute.exitstatus', exitstatus: exitstatus) if exitstatus != 0

        pattern = options[:stdout]
        if pattern.present?
          regexp = pattern.to_regexp

          # pattern is a string
          if regexp.nil? && stdout.exclude?(pattern)
            error << I18n.t('rubrics.item.errors.execute.stdout.string', string: pattern, stdin: stdin)
          end

          # pattern is a regexp
          unless regexp.nil? || regexp.match?(stdout)
            error << I18n.t('rubrics.item.errors.execute.stdout.regexp', regexp: regexp, stdin: stdin)
          end
        end

        [captures, error]
      end
    end
  end
end
