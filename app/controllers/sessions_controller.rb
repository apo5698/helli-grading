class SessionsController < ApplicationController
  def new
    render layout: 'pre_application'
  end

  def create
    if params[:user][:username] != '' and params[:user][:password] != ''
      session[:user] = params[:user]
      flash[:success] = '🐂🍺'
    else
      flash[:error] = '求你了输点东西吧qwq'
    end
    redirect_to root_path
  end

  def destroy
    flash[:info] = 'You have successfully signed out.'
    session[:user] = nil
    redirect_to root_path
  end
end
