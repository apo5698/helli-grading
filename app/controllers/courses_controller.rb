class CoursesController < ApplicationController
  before_action -> { @title = controller_name.classify.pluralize }

  #  GET /courses
  def index
    @courses = Course.all
    return unless flash[:modal_error]

    @course = Course.find_by(id: params[:course_id])
    @course ||= Course.new
    @course.assign_attributes(course_params)
  end

  #  GET /courses/new
  def new
    @course = Course.new
  end

  #  POST /courses
  def create
    course = Course.create!(course_params)

    flash[:success] = "Course '#{course}' created."
    redirect_to action: index, course: course_params, course_id: course.id
  end

  #  GET /courses/:id -> GET /courses
  def show
    redirect_to action: :index
  end

  #  PUT /courses/:id
  def edit
    @course = Course.find(params[:id])
  end

  #  DELETE /courses/:id
  def update
    course = Course.find(params[:id])
    course.update!(course_params)

    flash[:success] = "Course '#{course}' updated."
    redirect_to action: index, course: course_params, course_id: course.id
  end

  def destroy
    course = Course.find(params[:id])
    name = course.name
    course.destroy!

    flash[:success] = "Course '#{name}' deleted."
    redirect_back fallback_location: { action: :index }
  end

  def show_share; end

  private

  def course_params
    params.require(:course).permit(:name, :term, :section)
  end
end
