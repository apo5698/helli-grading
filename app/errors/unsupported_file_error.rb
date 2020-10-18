# Raised when given file has an incorrect file extension.
#
#    Process.javac('HelloWorld.txt')
#
# <em>raises the exception:</em>
#
#    UnsupportedFileError: unsupported file type
class UnsupportedFileError < StandardError; end
