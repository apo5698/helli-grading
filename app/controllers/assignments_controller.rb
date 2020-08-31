class AssignmentsController < ApplicationController
  def index
    @course = Course.find(params[:course_id])
    @assignments = @course.assignments
    return unless flash[:modal_error]

    @assignment = Assignment.find_by(id: params[:course_id])
    @assignment ||= Assignment.new
    @assignment.assign_attributes(assignment_params)
  end

  def new
    @assignment = Assignment.new
  end

  def create
    assignment = Assignment.new(assignment_params.merge(course_id: params[:course_id]))
    assignment.rubric = Rubric.create(name: "#{assignment} rubric", user_id: session[:user_id], visibility: false)
    assignment.save
    TsFile.create(assignment_id: assignment.id)
    messages = assignment.errors.full_messages
    if messages.blank?
      flash[:success] = "#{assignment.name} has been successfully created."
    else
      flash[:modal_error] = flash_errors(messages)
    end
    redirect_to action: index, assignment: assignment_params, id: assignment.id
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
    redirect_to action: index, assignment: assignment_params, id: assignment.id
  end

  def destroy
    assignment = Assignment.find(params[:id])
    flash[:success] = "#{assignment.name} has been successfully deleted."
    assignment.destroy
    redirect_to "/courses/#{params[:course_id]}/assignments"
  end

  def expected_file_add
    assignment = Assignment.find(params[:assignment_id])
    filename = "#{params[:expected_input_filename]}.java"

    saved_filenames = assignment.expected_input_filenames.split(';')
    if saved_filenames.include?(filename)
      flash[:error] = "#{filename} already exists."
    else
      saved_filenames.unshift(filename)
      assignment.expected_input_filenames = saved_filenames.join(';')
      assignment.save
      flash[:success] = "#{filename} added."
    end

    redirect_back(fallback_location: '')
  end

  def expected_file_delete
    assignment = Assignment.find(params[:assignment_id])
    filename = params[:added_input_filenames]

    saved_filenames = assignment.expected_input_filenames.split(';')
    saved_filenames.delete(filename)
    assignment.expected_input_filenames = saved_filenames.join(';')
    assignment.save

    flash[:success] = "#{filename} deleted."
    redirect_back(fallback_location: '')
  end

  private

  def assignment_params
    params.require(:assignment).permit(:assignment_type, :name, :description)
  end
end
