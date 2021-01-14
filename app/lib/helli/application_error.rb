# frozen_string_literal: true

module Helli
  # Abstract Helli application exceptions.
  class ApplicationError < StandardError; end

  # Raised when the specified file cannot be found.
  class FileNotFound < ApplicationError; end

  # Raised when the specified file has no content or only whitespace characters.
  class EmptyFileError < ApplicationError; end

  # Raised when the specified file is unsupported or having an invalid file extension.
  class UnsupportedFileType < ApplicationError; end

  # Raised when any error occurs during parsing data.
  class ParseError < ApplicationError; end

  # Raised if a submission does not match any participant.
  # For example, a user submits Day 1 worksheet, but then Day 2 submissions is uploaded.
  class StudentNotParticipated < ApplicationError; end

  class OAuthError < ApplicationError; end

  class OAuthUserExists < OAuthError
    def initialize
      super('Username or email has already been taken.')
    end
  end
end
