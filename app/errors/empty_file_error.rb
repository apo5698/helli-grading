# Raised when given file has no content.
#
#    Dependency.load('empty.yml')
#
# <em>raises the exception:</em>
#
#    EmptyFileError: empty dependencies file
class EmptyFileError < StandardError; end
