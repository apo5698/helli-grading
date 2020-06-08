class ApplicationController < ActionController::Base
  before_action :catch_denied_access

  private

  def access_allowed?
    session[:user]
  end

  def catch_denied_access
    return if access_allowed?

    flash[:error] = 'Access denied'
    redirect_to root_path
  end
end
