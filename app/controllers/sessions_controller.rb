class SessionsController < ApplicationController
  def new
    render layout: 'pre_application'
  end

  def create
    user = User.find_by(email: params[:user][:email])
    if !user.nil? && user.authenticate(params[:user][:password])
      session[:user] = user
    else
      flash[:error] = 'The email and password you entered did not match our ' \
                      'records. Please double-check and try again.'
    end
    redirect_to root_path
  end

  def destroy
    flash[:info] = 'You have successfully signed out.'
    session[:user] = nil
    redirect_to root_path
  end
end
