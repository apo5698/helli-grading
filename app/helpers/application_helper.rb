module ApplicationHelper
  include HTMLTemplate

  def current_user?(uid)
    uid == current_user.id
  end
end
