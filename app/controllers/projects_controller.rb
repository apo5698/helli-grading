class ProjectsController < GradingController
  def index
    @assignments = Project.all
    @assignment = Project.new
  end

  def destroy
    assignment = Project.find(params[:id])
    name = assignment.name
    FileUtils.rm_rf @user_root.join('projects', assignment.id.to_s)
    assignment.destroy
    flash[:success] = "#{name} has been successfully deleted"
    redirect_to '/grading/projects'
  end
end
