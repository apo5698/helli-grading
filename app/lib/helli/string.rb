# frozen_string_literal: true
module Helli
  # Custom string class.
  module String
    class << self
      # This is an alternative implementation of ruby's built-in +format()+ method, which is able to
      # handle undefined keys. It replaces variables in a string to given replacements.
      #
      # Variables in string must follow the format of %{var}.
      #
      #   string = '%{filename} contains %{error_count} checkstyle warning(s).'
      #
      #   Helli::String.replace(str, filename: "HelloWorld.java", error: 5)
      #     #=> "HelloWorld.java contains 5 checkstyle warning(s)."
      #
      # Undefined keys will be ignored:
      #
      #   Helli::String.replace(str, exitstatus: 0, error_count: 5, output: "???")
      #     #=> "%{filename} contains 5 checkstyle warning(s)."
      #
      # @param [String] string string to process
      # @param [Hash] reps replacements
      # @return [String] result
      def replace(string, **reps)
        reps.reduce(string) { |result, r| result.gsub("%{#{r[0]}}", r[1].to_s) }
      end
    end
  end
end
