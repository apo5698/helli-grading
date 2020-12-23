class ApplicationController < ActionController::Base
  before_action :catch_denied_access

  before_action lambda {
    @title = 'AGS-dev'
  }

  rescue_from ActiveRecord::RecordInvalid do |e|
    app_logger.error(e.message)
    flash[:error] = e.message
    redirect_back fallback_location: ''
  end

  # Returns a logger with params and custom tags.
  #
  # @param [Hash] tags custom tags
  # @return [::Logger] a Logger object
  def app_logger(**tags)
    logger_tags =
      { url: request.url,
        ip: request.ip,
        user_id: session[:user_id],
        params: params.to_unsafe_h }.merge(tags)

    Helli::Logger.new(logger_tags)
  end

  private

  def access_allowed?
    session[:user_id]
  end

  def current_user
    User.find(session[:user_id])
  end

  def catch_denied_access
    return if access_allowed?

    flash[:error] = 'Access denied.'
    redirect_back fallback_location: '/'
  end

  def flash_errors(messages)
    return if messages.blank?

    flash.now[:error] = (messages.uniq.reject(&:blank?).join('.<br>') << '.').html_safe
  end

  def flash_modal_errors(messages)
    return if messages.blank?

    flash.now[:modal_error] = (messages.uniq.reject(&:blank?).join('.<br>') << '.').html_safe
  end
end
