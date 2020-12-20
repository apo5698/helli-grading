class CoursesController < ApplicationController
  before_action lambda {
    @title = controller_name.classify.pluralize
    id = params[:id] || params[:course_id]
    @course = Course.find(id) if id
  }

  #  GET /courses
  def index
    @courses = Course.of(session[:user_id])
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
    begin
      course = Course.create!(course_params.merge(user_id: session[:user_id]))
      flash[:success] = "Course #{course.name} created."
    rescue StandardError => e
      flash[:error] = e.message
    end

    redirect_back fallback_location: { action: :index }
  end

  #  GET /courses/:id -> GET /courses
  def show
    redirect_to action: :index
  end

  #  GET /courses/:id/edit
  def edit
    @course = Course.find(params[:id])
  end

  #  PUT /courses/:id
  def update
    course = Course.find(params[:id])
    course.update_attributes(course_params)

    messages = course.errors.full_messages
    if messages.blank?
      flash[:success] = "#{course} has been successfully updated."
    else
      flash_modal_errors(messages)
    end
    redirect_to action: index, course: course_params, course_id: course.id
  end

  #  DELETE /courses/:id
  def destroy
    course = Course.find(params[:id])
    flash[:success] = "#{course} has been successfully deleted."
    course.destroy
    redirect_to '/courses'
  end

  #  GET /courses/:course_id/share
  def share
    @course = Course.find(params[:course_id])
    @permitted_users = @course.permitted_users(current_user)
  end

  #  PUT /courses/:course_id/share
  def add_share
    @course = Course.find(params[:course_id])
    email = params.require(:email)
    user = User.find_by(email: email)
    if user.nil?
      flash[:error] = "User #{email} does not exist."
    elsif user.in?(@course.permitted_users)
      flash[:error] = "User #{user} has already been added to #{@course}."
    else
      @course.collaborator_ids << user.id
      flash[:success] = "User #{user} has been added as collaborator."
    end
    @course.save!

    redirect_to '/courses'
  end

  #  DELETE /courses/:course_id/share
  def delete_share
    if current_user.in?(@course.permitted_users)
      user = User.find(params.require(:uid))
      @course.collaborator_ids.delete(user.id)
      @course.save!
      flash[:success] = "User #{user} has been removed from collaborators."
    else
      flash[:error] = 'You are not allowed to perform this action.'
    end

    redirect_to '/courses'
  end

  def copy
    @course.super_dup

    flash[:success] = "Course #{@course} has been successfully copied over."
    redirect_to action: :index
  end

  private

  def course_params
    params.require(:course).permit(:name, :term, :section)
  end
end
