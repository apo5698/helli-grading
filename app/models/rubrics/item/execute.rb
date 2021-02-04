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
        captures = JDK.java(
          filename,
          options[:arguments],
          libraries: options[:libraries],
          stdin: options[:stdin],
          timeout: options[:timeout]
        )
        stderr = captures[1]

        error_count = 0
        # runtime errors
        error_count += 1 if stderr.include?('Exception in thread')
        # rare situation
        error_count += 1 if stderr.include?('java.lang.NoClassDefFoundError')

        [captures, error_count]
      end
    end
  end
end
