class HomeworkController < ApplicationController
  def index
    @controller = params[:controller]
    @assignments = Homework.all
    @assignment = Homework.new
    render '/grading/index'
  end
end
