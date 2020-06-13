class ProjectsController < GradingController
  def index
    super(Object.const_get('Project'))
  end

  def new
    super(Object.const_get('Project'))
  end

  def destroy
    super
    remove_subdirectories @user_root.join('projects', @id.to_s)
  end

  private

  def assignment_params
    params.require(:project).permit(:name, :type, :term,
                                    :course, :section, :description)
  end
end
