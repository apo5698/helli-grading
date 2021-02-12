# frozen_string_literal: true

module Rubrics
  module Criterion
    class Checkstyle < Base
      # Pass if there are no checkstyle warnings, fail otherwise.
      def validate
        deduct_if @grade_item.error.count.positive?, for_each: @grade_item.error.count
      end
    end
  end
end
