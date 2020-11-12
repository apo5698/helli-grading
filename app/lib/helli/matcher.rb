module Helli
  class Matcher
    def initialize(expected, actual, level = 0)
      @expected = expected
      @actual = actual
      @level = level

      @checker = DidYouMean::SpellChecker.new(dictionary: [])
    end

    def match; end

    # Matches every single character.
    def strict_match
      @expected == @actual
    end

    # Matches word characters (a-zA-Z0-9_) only.
    def word_match
      @expected.gsub(/[^\w]/, '') == @actual.gsub(/[^\w]/, '')
    end

    def ignore_whitespace_match
      @expected.gsub(/\s/, '') == @actual.gsub(/\s/, '')
    end

    # Matches partial characters.
    def fuzzy_match(threshold:) end
  end
end
