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

      def run(key, options)
        actual = Redis.current.get(key).to_f
        scale = options[:scale].reduce([]) { |arr, level| arr << [level[:total], level[:point]] }.to_h
        scale[scale.keys.find { |total| actual > total }] || 0
      end
    end
  end
end
