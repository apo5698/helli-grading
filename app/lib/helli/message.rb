module Helli
  module Message
    class << self
      # An error message indicating that a manual resolution is needed.
      def resolve_manually(msg)
        "#{msg}, please resolve manually"
      end

      # This is an alternative implementation of ruby's built-in +format()+ method, which is able to
      # handle undefined keys. It replaces variables in a string to given replacements.
      #
      # Variables in string must follow the format of %{var}.
      #
      #   string = '%{filename} contains %{error} checkstyle warning(s).'
      #
      #   format(string, filename: 'HelloWorld.java', error: 5)
      #     #=> 'HelloWorld.java contains 5 checkstyle warning(s).'
      #
      # Undefined keys will be ignored:
      #
      #   format(string, exitcode: 0, error: 5, output: '???')
      #     #=> '%{filename} contains 5 checkstyle warning(s).'
      def format(string, reps)
        reps.reduce(string) { |result, r| result.gsub("%{#{r[0]}}", r[1].to_s) }
      end
    end
  end
end
