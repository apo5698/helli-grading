# frozen_string_literal: true

module Rubrics
  module Item
    # Rubric for calculating zyBooks grades.
    class Zybooks < Base
      class << self
        def default_criteria
          [
            { type: 'Rubrics::Criterion::Range', action: :award, point: 5.0 }
          ]
        end
      end

      def to_s
        "[#{basename}]"
      end

      # Run grading on a file with options.
      #
      # @param [String] key redis key
      # @param [Hash, ActionController::Parameters] options
      # @return [Array] [point, error]
      def run(key, options)
        actual = Redis.current.get(key).to_f
        scale = options[:scale].reduce([]) { |arr, level| arr << [level[:total], level[:point]] }.to_h
        point = scale[scale.keys.find { |total| actual >= total }] || 0

        error = []
        error << "Total: #{actual} => #{point.to_f}" if point != maximum_points

        [point, error]
      end
    end
  end
end
