# frozen_string_literal: true

module Rubrics
  module Item
    # Merges compile and execute.
    class CompileExecute < Base
      class << self
        def default_criteria
          Rubrics::Item::Compile.default_criteria + Rubrics::Item::Execute.default_criteria
        end

        def requirements
          [:filename]
        end
      end

      # TODO: implement
      # +test_file+ not used
      def grade(filename, options)
        raise NotImplementedError
      end
    end
  end
end
