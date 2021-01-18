require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Loads .env file.
Dotenv::Railtie.load

module Helli
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # config.active_job.queue_adapter = :sidekiq

    config.after_initialize do
      # only load dependencies when running server
      next unless defined?(Puma::DSL) || defined?(Rails::Server)

      Dependency.setup
    end

    # Use custom error pages as defined in routes.rb
    config.exceptions_app = routes

    # Render TypeScript
    config.react.server_renderer_extensions = %w[jsx js tsx ts]

    # Convert JSON keys to camelCase
    ActiveModelSerializers.config.key_transform = :camel_lower
  end
end
