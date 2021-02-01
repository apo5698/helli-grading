# frozen_string_literal: true

module Api
  class ApplicationController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid do |exception|
      render json: exception, status: :unprocessable_entity
    end
  end
end
