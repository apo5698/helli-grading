# frozen_string_literal: true

module Rubrics
  module Criterion
    class Checkstyle < Base
      # Pass if there are no checkstyle warnings, fail otherwise.
      def validate
        deduct_if @grade_item.error.positive?, for_each: @grade_item.error
      end
    end
  end
end
