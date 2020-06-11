class HomeworkController < GradingController
  def index
    super
    @assignments = Homework.all
  end

  def destroy
    super
    remove_subdirectories @user_root.join('homework', @id.to_s)
  end
end
