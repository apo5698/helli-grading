class ApplicationController < ActionController::Base
  include Devise::Controllers::Helpers

  # Disable CSRF protection for ajax requests
  skip_before_action :verify_authenticity_token

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActiveRecord::RecordInvalid do |e|
    flash.alert = e.message
    redirect_back fallback_location: root_path
  end

  # Returns a logger with params and custom tags.
  #
  # @param [Hash] tags custom tags
  # @return [::Logger] a Logger object
  def app_logger(**tags)
    logger_tags =
      { url: request.url,
        ip: request.ip,
        user_id: current_user.id,
        params: params.to_unsafe_h }.merge(tags)

    Helli::Logger.new(logger_tags)
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: %i[email password])
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name username email password password_confirmation])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name username email password password_confirmation])
  end
end
