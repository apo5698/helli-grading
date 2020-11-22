module Helli
  # Abstract Helli exceptions.
  class Error < StandardError; end

  # All file-related exceptions.
  class FileError < Error; end

  # Raised when the specified file cannot be found.
  class FileNotFoundError < FileError
    def initialize(filename)
      super "#{filename} not found"
    end
  end

  # Raised when the specified file has no content or only whitespace characters.
  class EmptyFileError < FileError; end

  # Raised when the specified file is unsupported or having an invalid file extension.
  class UnsupportedFileTypeError < FileError
    def initialize(extname)
      super "unsupported file type #{extname}"
    end
  end

  # Raised when any error occurs during parsing data.
  class ParseError < Error; end
end