class SessionsController < ApplicationController
  def new
    render layout: 'pre_application'
  end

  def create
    user = User.find_by(email: params[:user][:email])
    if user.authenticate(params[:user][:password])
      session[:user] = user
    else
      flash[:error] = '慢慢改～'
    end
    redirect_to root_path
  end

  def destroy
    flash[:info] = 'You have successfully signed out.'
    session[:user] = nil
    redirect_to root_path
  end
end
