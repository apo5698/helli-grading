class ProjectsController < GradingController
  def index
    super
    @assignments = Project.all
  end

  def create
    super
    if @messages.blank?
      assignment_path = @user_root.join('projects', @assignment.id.to_s)
      make_subdirectories assignment_path
    end
  end

  def destroy
    super
    remove_subdirectories @user_root.join('projects', @id.to_s)
  end
end
