# frozen_string_literal: true

module Rubrics
  module Criterion
    class Checkstyle < Base
      # Pass if there are no checkstyle warnings, fail otherwise.
      def validate
        pass_if @grade_item.error.positive?
      end
    end
  end
end
