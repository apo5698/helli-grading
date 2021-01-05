module Helli
  # Abstract Helli exceptions.
  class Error < StandardError; end

  # All file-related exceptions.
  # class FileError < Error; end

  # Raised when the specified file cannot be found.
  class FileNotFoundError < StandardError
    def initialize(msg)
      super "#{msg} not found"
    end
  end

  # Raised when the specified file has no content or only whitespace characters.
  class EmptyFileError < StandardError; end

  # Raised when the specified file is unsupported or having an invalid file extension.
  class UnsupportedFileTypeError < StandardError
    def initialize(msg)
      super "unsupported file type #{msg}"
    end
  end

  # Raised when any error occurs during parsing data.
  class ParseError < StandardError; end
end