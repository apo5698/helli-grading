class AssignmentsController < AssignmentsViewController
  before_action -> { @pattern = Helli::Process::Java::FILENAME_REGEXP_STR }
  #  GET /courses/:course_id/assignments
  def index
    @title = controller_name.classify.pluralize
    @assignments = @course.assignments
    return unless flash[:modal_error]

    @assignment ||= Assignment.new
    @assignment.assign_attributes(assignment_params)
  end

  #  GET /courses/:course_id/assignments/new
  def new
    @assignment = Assignment.new
  end

  #  POST /courses/:course_id/assignments
  def create
    # begin
    assignment = Assignment.create!(assignment_params.merge(course_id: params[:course_id]))
    flash[:success] = "Assignment #{assignment.name} created."
    # rescue StandardError => e
    #   flash[:error] = e.message
    # end

    redirect_back fallback_location: { action: :index }
  end

  #  GET /courses/:course_id/assignments/:id
  def show
    @title = @assignment.name
  end

  #  PUT /courses/:course_id/assignments/:id
  def update
    assignment = Assignment.find(params[:id])
    assignment.update(assignment_params.merge(course_id: params[:course_id]))
    messages = assignment.errors.full_messages
    if messages.blank?
      flash[:success] = "#{assignment.name} has been successfully updated."
    else
      flash_modal_errors(messages)
    end
    redirect_to action: index, assignment: assignment_params, id: assignment.id
  end

  #  DELETE /courses/:course_id/assignments/:id
  def destroy
    assignment = Assignment.find(params[:id])
    flash[:success] = "#{assignment.name} has been successfully deleted."
    assignment.destroy
    redirect_to "/courses/#{params[:course_id]}/assignments"
  end

  #  PUT /courses/:course_id/assignments/:id/programs
  def program_add
    name = params.require(:name)

    begin
      @assignment.add_program(name)
      @assignment.save
      flash[:success] = "#{name} added."
    rescue StandardError => e
      flash[:error] = e.message
    end

    redirect_back(fallback_location: '')
  end

  #  DELETE /courses/:course_id/assignments/:id/programs?name=#{name}
  def program_delete
    name = params.require(:name)

    begin
      @assignment.delete_program(name)
      @assignment.save
      flash[:success] = "#{name} deleted."
    rescue StandardError => e
      flash[:error] = e.message
    end

    redirect_back(fallback_location: '')
  end

  #  PUT /courses/:course_id/assignments/:id/input_files
  def input_file_add
    file = params.require(:file)

    begin
      @assignment.input_files.attach(file)
      flash[:success] = "#{file.original_filename} added."
    rescue StandardError => e
      flash[:error] = e.message
    end

    redirect_back(fallback_location: '')
  end

  #  DELETE /courses/:course_id/assignments/:id/input_files?name=#{name}
  def input_file_delete
    filename = params.require(:name)

    begin
      Helli::Attachment.delete_by_name(@assignment.input_files, filename)
      flash[:success] = "#{filename} deleted."
    rescue StandardError => e
      flash[:error] = e.message
    end

    redirect_back(fallback_location: '')
  end

  private

  def assignment_params
    params.require(:assignment).permit(:name, :category, :description)
  end
end
