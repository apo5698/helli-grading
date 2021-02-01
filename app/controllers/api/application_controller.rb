# frozen_string_literal: true

module Api
  class ApplicationController < ActionController::API
    rescue_from ActiveRecord::RecordInvalid do |exception|
      render json: exception, status: :unprocessable_entity
    end

    rescue_from ActiveRecord::RecordNotFound do |exception|
      render json: exception, status: :not_found
    end
  end
end
