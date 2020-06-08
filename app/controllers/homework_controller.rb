class HomeworkController < ApplicationController
  def index
    @controller = params[:controller]
    render '/grading/index'
  end
end
