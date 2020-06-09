class ExercisesController < ApplicationController
  def index
    @controller = params[:controller]
    @assignments = Exercise.all
    @assignment = Exercise.new
    render '/grading/index'
  end
end
