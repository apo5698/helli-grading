class HomeworkController < GradingController
  def index
    super(Object.const_get('Homework'))
  end

  def new
    super(Object.const_get('Homework'))
  end

  def destroy
    super
    remove_subdirectories @user_root.join('homework', @id.to_s)
  end

  private

  def assignment_params
    params.require(:homework).permit(:name, :type, :term,
                                     :course, :section, :description)
  end
end
