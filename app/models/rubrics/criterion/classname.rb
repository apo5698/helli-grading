# frozen_string_literal: true

module Rubrics
  module Criterion
    class Classname < Base
      # Find the class name and see if it matches the filename without extension.
      # TODO: Using regexp is not a reliable solution. Consider using abstract syntax tree.
      def validate
        actual = @grade_item.content.match(/(?<=public class )\w+/)[0]
        expected = File.basename(@grade_item.filename, '.java')

        pass_if actual == expected
      end
    end
  end
end
