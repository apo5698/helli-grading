class AssignmentsController < ApplicationController
  def index
    @course = Course.find(params[:course_id])
    @assignments = @course.assignments
  end

  def new; end
  def create; end

  def show
    @course = Course.find(params[:course_id])
    @assignment = Assignment.find(params[:id])
  end

  def edit; end
  def update; end
  def destroy; end
end
