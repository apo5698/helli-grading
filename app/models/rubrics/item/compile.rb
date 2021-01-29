# frozen_string_literal: true

module Rubrics
  module Item
    # Rubric for compiling a Java file.
    class Compile < Base
      class << self
        def default_criteria
          [
            { type: 'Rubrics::Criterion::Filename', action: :award, point: 1.0 },
            { type: 'Rubrics::Criterion::Compile', action: :award, point: 1.0 }
          ]
        end

        def requirements
          [:filename]
        end
      end

      def run(filename, options)
        captures = JDK.javac(filename, options[:arguments], libraries: options[:libraries])

        # only matches "* error(s)" at the end of stderr
        # match returns +nil+ if no match found
        error_count = captures[2].exitstatus.zero? ? 0 : captures[1].match(/\d+(?= errors?)/)[0] || 0

        [captures, error_count]
      end
    end
  end
end
