# frozen_string_literal: true

module Rubrics
  module Criterion
    class MaximumPoint < Base
      # Just let it pass...
      def validate
        award_point
      end
    end
  end
end
