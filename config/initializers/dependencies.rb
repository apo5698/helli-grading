# Only loads dependencies when running server, not during tasks
if defined?(::Rails::Server)
  Helli::Dependency.load('config/dependencies.yml')
  Helli::Dependency.download_all
end
