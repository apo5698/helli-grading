# frozen_string_literal: true

module Rubrics
  module Item
    # Rubric for calculating zyBooks grades.
    class Zybooks < Base
      class << self
        def default_criteria
          []
        end

        def requirements
          [:file]
        end
      end

      def run(_, options) end
    end
  end
end
