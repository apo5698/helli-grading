class UsersController < ApplicationController
  def new
    flash[:info] = 'Registered.'
    redirect_to root_path
  end

  def create; end
end
