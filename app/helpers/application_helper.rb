module ApplicationHelper
  include HTMLTemplate

  def current_user?(uid)
    uid == session[:user_id]
  end
end
