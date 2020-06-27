class AssignmentsController < ApplicationController
  def index
    @course = Course.find(params[:course_id])
    @assignments = @course.assignments
  end

  def new; end

  def create
    assignment = Assignment.create(assignment_params.merge(course_id: params[:course_id]))
    messages = assignment.errors.full_messages
    if messages.blank?
      flash[:success] = "#{assignment.name} has been successfully created."
    else
      flash[:modal_error] = flash_errors(messages)
    end
    redirect_to "/courses/#{params[:course_id]}/assignments"
  end

  def show
    @course = Course.find(params[:course_id])
    @assignment = Assignment.find(params[:id])
  end

  def edit
    @course = Course.find(params[:course_id])
    @assignment = Assignment.find(params[:id])
  end

  def update
    assignment = Assignment.find(params[:id])
    assignment.update_attributes(assignment_params.merge(course_id: params[:course_id]))
    messages = assignment.errors.full_messages
    if messages.blank?
      flash[:success] = "#{assignment.name} has been successfully updated."
    else
      flash[:modal_error] = flash_errors(messages)
    end
    redirect_to "/courses/#{params[:course_id]}/assignments"
  end

  def destroy
    assignment = Assignment.find(params[:id])
    flash[:success] = "#{assignment.name} has been successfully deleted."
    assignment.destroy
    redirect_to "/courses/#{params[:course_id]}/assignments"
  end

  private

  def assignment_params
    params.require(:assignment).permit(:assignment_type, :name, :description)
  end
end
