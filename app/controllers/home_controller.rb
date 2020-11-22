class HomeController < ApplicationController
  before_action :catch_denied_access, except: :index
  before_action -> { @title = controller_name.classify }

  def index
    if session[:user_id]
      @user_email = User.find(session[:user_id]).email
    else
      redirect_to '/sessions/new'
    end
  end
end
