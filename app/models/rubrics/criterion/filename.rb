# frozen_string_literal: true

module Rubrics
  module Criterion
    class Filename < Base
      def validate
        pass_if @grade_item.attachment.present?
      end
    end
  end
end
