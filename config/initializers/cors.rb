# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:3000', '127.0.0.1:3000', 'lvh.me:3000', 'helli.app'
    resource '*', headers: :any, methods: %i[get post patch put delete]
  end
end
