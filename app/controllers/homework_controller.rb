class HomeworkController < GradingController
  def index
    @assignments = Homework.all
    @assignment = Homework.new
  end

  def new
    @assignment = Homework.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    assignment = Assignment.create(assignment_params)
    if assignment
      assignment_path = @user_root.join('homework', assignment.id.to_s)
      flash[:success] = "#{assignment.name} has been successfully created."
    else
      flash[:error] = "Error occurred when creating #{assignment.name}"
    end
    redirect_to '/grading/homework'
  end

  def destroy
    assignment = Homework.find(params[:id])
    name = assignment.name
    FileUtils.rm_rf @user_root.join('homework', assignment.id.to_s)
    assignment.destroy
    flash[:success] = "#{name} has been successfully deleted"
    redirect_to '/grading/homework'
  end

  def edit
    @assignments = Homework.all
    @assignment = Homework.find(params[:id])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    assignment = Homework.find(params[:id])
    assignment.update_attributes(assignment_params)
    flash[:success] = "#{assignment.name} has been successfully updated."
    redirect_to '/grading/homework'
  end
end
