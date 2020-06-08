class HomeController < ApplicationController
  before_action :catch_denied_access, except: :index

  def index
    if session[:user]
    else
      redirect_to '/sessions/new'
    end
  end
end
