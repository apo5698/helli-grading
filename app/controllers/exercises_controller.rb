class ExercisesController < GradingController
  def index
    @assignments = Exercise.all
    @assignment = Exercise.new
  end

  def new
    @assignment = Exercise.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    assignment = Assignment.create(assignment_params)
    if assignment
      assignment_path = @user_root.join('exercises', assignment.id.to_s)
      FileUtils.mkdir_p assignment_path.join('bin')
      FileUtils.mkdir_p assignment_path.join('src')
      FileUtils.mkdir_p assignment_path.join('test')
      FileUtils.mkdir_p assignment_path.join('test_files')
      flash[:success] = "#{assignment.name} has been successfully created."
    else
      flash[:error] = "Error occurred when creating #{assignment.name}"
    end
    redirect_to '/grading/exercises'
  end

  def destroy
    assignment = Exercise.find(params[:id])
    name = assignment.name
    FileUtils.rm_rf @user_root.join('exercises', assignment.id.to_s)
    assignment.destroy
    flash[:success] = "#{name} has been successfully deleted"
    redirect_to '/grading/exercises'
  end

  def edit
    @assignment = Exercise.find(params[:id])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    assignment = Exercise.find(params[:id])
    assignment.update_attributes(assignment_params)
    flash[:success] = "#{assignment.name} has been successfully updated."
    redirect_to '/grading/exercises'
  end
end
