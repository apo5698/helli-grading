class ProjectsController < GradingController
  def index
    @assignments = Project.all
    @assignment = Project.new
  end

  def new
    @assignment = Project.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    assignment = Assignment.create(assignment_params)
    if assignment
      assignment_path = @user_root.join('projects', assignment.id.to_s)
      FileUtils.mkdir_p assignment_path.join('bin')
      FileUtils.mkdir_p assignment_path.join('src')
      FileUtils.mkdir_p assignment_path.join('test')
      FileUtils.mkdir_p assignment_path.join('test_files')
      flash[:success] = "#{assignment.name} has been successfully created."
    else
      flash[:error] = "Error occurred when creating #{assignment.name}"
    end
    redirect_to '/grading/projects'
  end

  def destroy
    assignment = Project.find(params[:id])
    name = assignment.name
    FileUtils.rm_rf @user_root.join('projects', assignment.id.to_s)
    assignment.destroy
    flash[:success] = "#{name} has been successfully deleted"
    redirect_to '/grading/projects'
  end

  def edit
    @assignments = Project.all
    @assignment = Project.find(params[:id])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    assignment = Project.find(params[:id])
    assignment.update_attributes(assignment_params)
    flash[:success] = "#{assignment.name} has been successfully updated."
    redirect_to '/grading/projects'
  end
end
