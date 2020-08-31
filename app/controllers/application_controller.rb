class ApplicationController < ActionController::Base
  before_action :catch_denied_access
  before_action :set_variables

  private

  def access_allowed?
    session[:user_id]
  end

  def catch_denied_access
    return if access_allowed?

    flash[:error] = 'Access denied'
    redirect_to '/'
  end

  def flash_errors(messages)
    messages.uniq.reject(&:blank?).join(".\n") << '.'
  end

  def set_variables
    @course = Course.find_by(id: params[:course_id])
    @assignment = Assignment.find_by(id: params[:assignment_id])
  end
end
