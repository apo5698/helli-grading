module Helli
  # Abstract Helli exceptions.
  class Error < StandardError; end

  # All file-related exceptions.
  class FileError < Error; end

  # Raised when the specified file cannot be found.
  class FileNotFoundError < FileError; end

  # Raised when the specified file has no content or only whitespace characters.
  class EmptyFileError < FileError; end

  # Raised when the specified file is unsupported or having an invalid file extension.
  class UnsupportedFileError < FileError; end

  # Raised when any error occurs during parsing data.
  class ParseError < Error; end
end