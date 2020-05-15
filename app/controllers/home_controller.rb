class HomeController < ApplicationController
  def index
    if session[:user]
    else
      redirect_to '/sessions/new'
    end
  end
end
