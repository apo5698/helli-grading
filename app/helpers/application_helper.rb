module ApplicationHelper
  include HTMLTemplate
  include GradingHelper

  def current_user?(uid)
    uid == current_user.id
  end
end
