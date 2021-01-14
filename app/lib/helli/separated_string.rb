# frozen_string_literal: true

module Helli
  # Encapsulates a string array and provides some convenient operations.
  class SeparatedString
    attr_accessor :trailing_separator

    def initialize(*string, separator: '; ')
      @feedback = Array(string)
      @separator = separator
    end

    def <<(string)
      @feedback << string
      self
    end

    # Returns a string separated by the separator.
    #
    # @return [String] separated string
    def join
      str = @feedback.join(@separator)
      str << @separator.strip if @trailing_separator
      str
    end

    def to_s
      join
    end
  end
end
