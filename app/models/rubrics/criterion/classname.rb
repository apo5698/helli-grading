# frozen_string_literal: true

module Rubrics
  module Criterion
    class Classname < Base
      # Find the class name and see if it matches the filename without extension.
      # TODO: Using regexp is not a reliable solution. Consider using abstract syntax tree.
      def validate
        actual = @grade_item.content.match(/(?<=public class )\w+/)
        if actual.nil?
          error!
        else
          expected = File.basename(@grade_item.filename, '.*')
          award_if actual[0] == expected
        end
      end
    end
  end
end
