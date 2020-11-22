# Only loads dependencies when running server, not during tasks
if defined?(::Rails::Server)
  Dependency.load('config/dependencies.yml')
  Dependency.download_all
end
