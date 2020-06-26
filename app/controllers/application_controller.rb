class ApplicationController < ActionController::Base
  before_action :catch_denied_access

  private

  def access_allowed?
    session[:user_id]
  end

  def catch_denied_access
    return if access_allowed?

    flash[:error] = 'Access denied'
    redirect_to '/'
  end

  def flash_errors(messages)
    messages.uniq.reject(&:blank?).join(".\n") << '.'
  end
end
