module ApplicationHelper
  include HTMLTemplate
  include GradingHelper

  def current_user?(uid)
    uid == session[:user_id]
  end
end
