class CoursesController < ApplicationController
  def index
    @courses = Course.all
  end

  def new; end

  def create
    course = Course.create(course_params)
    messages = course.errors.full_messages
    if messages.blank?
      flash[:success] = "#{course} has been successfully created."
    else
      flash[:modal_error] = flash_errors(messages)
    end
    redirect_to '/courses'
  end

  def share; end

  def edit
    @course = Course.find(params[:id])
  end

  def update
    course = Course.find(params[:id])
    course.update_attributes(course_params)

    messages = course.errors.full_messages
    if messages.blank?
      flash[:success] = "#{course} has been successfully updated."
    else
      flash[:modal_error] = flash_errors(messages)
    end
    redirect_to '/courses'
  end

  def destroy
    course = Course.find(params[:id])
    flash[:success] = "#{course} has been successfully deleted."
    course.destroy
    redirect_to '/courses'
  end

  def show_share; end

  private

  def course_params
    params.require(:course).permit(:name, :term, :section)
  end
end
