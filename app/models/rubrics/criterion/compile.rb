# frozen_string_literal: true

module Rubrics
  module Criterion
    class Compile < Base
      def validate
        award_if @grade_item.exitstatus.zero? && @grade_item.stderr.empty?
      end
    end
  end
end
