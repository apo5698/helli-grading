class HomeController < ApplicationController
  # Suppress Devise error message
  skip_before_action :authenticate_user!

  before_action -> { @title = controller_name.classify }

  #  GET /
  def index
    # Suppress Devise error message
    redirect_to new_user_session_path unless user_signed_in?
  end
end
