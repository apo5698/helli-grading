class ApplicationController < ActionController::Base
  before_action :catch_denied_access
  before_action -> { @title = 'AGS-dev' }

  private

  def access_allowed?
    session[:user_id]
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
