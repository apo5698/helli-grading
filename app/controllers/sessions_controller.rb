class SessionsController < ApplicationController
  before_action :catch_denied_access, except: %i[new create]

  def new
    @recovery_email = params[:recovery_email]
    render layout: 'pre_application'
  end

  def create
    user = User.find_by(email: params[:email])
    if !user.nil? && user.authenticate(params[:password])
      flash.notice = 'You have been successfully signed in.'
      session[:user_id] = user.id
    else
      flash.alert = 'The email and password you entered did not match our ' \
                      'records. Please double-check and try again.'
    end
    redirect_to '/'
  end

  def destroy
    flash.notice = 'You have successfully signed out.'
    session[:user_id] = nil
    redirect_to '/'
  end
end
