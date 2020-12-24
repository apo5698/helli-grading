# frozen_string_literal: true

return unless defined?(Puma::DSL) || defined?(Rails::Server)

begin
  installed = Gem::Version.new(`javac --version`.match(/(?<=javac ).+/)[0])
  required = Gem::Version.new(11)
  raise StandardError, "require JDK #{required} or later, but found: #{installed}" if installed < required
rescue Errno::ENOENT
  raise StandardError, 'java is not installed'
end
