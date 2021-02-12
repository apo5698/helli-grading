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
        capture = JDK.javac(filename, options[:arguments], libraries: options[:libraries])

        error = []
        error << capture.stderr.strip.split("\n").last unless capture.exitstatus.zero?

        [capture, error]
      end
    end
  end
end
