class SessionsController < ApplicationController
  def new
    render layout: 'pre_application'
  end

  def create
    email = params[:user][:email]
    password = params[:user][:password]
    if email != '' or password != ''
      user = User.find_by(email: email, password: password)
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
