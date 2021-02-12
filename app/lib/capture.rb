# frozen_string_literal: true

# Encapsulates captures returned from Open3
class Capture
  attr_accessor :stdout, :stderr
  attr_reader :command, :status

  delegate :exitstatus, to: :status

  def initialize(command = nil, capture = nil, stdout: nil, stderr: nil, status: nil)
    @command = command
    @stdout = stdout || capture[0]
    @stderr = stderr || capture[1]
    @status = status || capture[2]
  end

  def remove_first(descriptor, regexp)
    raise InvalidDescriptor, descriptor if %i[stdout stderr].exclude?(descriptor)

    var = "@#{descriptor}"
    original = instance_variable_get(var)
    instance_variable_set(var, original.sub(regexp, ''))

    self
  end

  def remove_all(descriptor, regexp)
    raise InvalidDescriptor, descriptor if %i[stdout stderr].exclude?(descriptor)

    var = "@#{descriptor}"
    original = instance_variable_get(var)
    instance_variable_set(var, original.gsub(regexp, ''))

    self
  end

  def remove_line(descriptor, regexp)
    raise InvalidDescriptor, descriptor if %i[stdout stderr].exclude?(descriptor)

    var = "@#{descriptor}"
    original = instance_variable_get(var)
    instance_variable_set(var, original.split("\n").grep_v(regexp).join("\n"))

    self
  end

  # Raised when passed descriptor is not one of stdout and stderr.
  class InvalidDescriptor < Helli::ApplicationError
    def initialize(descriptor)
      super("Invalid descriptor - #{descriptor}. Expected :stdout or :stderr")
    end
  end
end
