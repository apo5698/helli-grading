# only load dependencies when running server
return unless defined?(Puma::DSL) || defined?(Rails::Server)

Helli::Dependency.setup
