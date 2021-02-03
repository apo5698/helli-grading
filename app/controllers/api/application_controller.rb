# frozen_string_literal: true

module Api
  class ApplicationController < ActionController::API
    rescue_from ActiveRecord::RecordInvalid do |exception|
      render json: exception, status: :unprocessable_entity
    end

    rescue_from ActiveRecord::RecordNotFound do |exception|
      render json: exception, status: :not_found
    end

    rescue_from Encoding::UndefinedConversionError do |exception|
      render plain: "#{exception.class.name} - #{exception}", status: :internal_server_error
    end
  end
end
