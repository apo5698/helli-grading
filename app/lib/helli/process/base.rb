require 'open3'

# Creates child processes to run commands. Returns a hash:
#
#    { stdout: ..., stderr: ..., exitcode: ... }
#
# +stdout+ and +stderr+ will be empty string instead of +nil+, if nothing happened.
module Base
end
