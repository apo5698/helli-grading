class UsersController < ApplicationController
  def new
    render layout: 'pre_application'
  end

  def create
    session[:user] = params[:user]
    flash[:success] = '🐂🍺'
    redirect_to root_path
  end

  def show

  end
end
