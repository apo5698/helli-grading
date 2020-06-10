class HomeworkController < GradingController
  def index
    @assignments = Homework.all
    @assignment = Homework.new
  end

  def destroy
    assignment = Homework.find(params[:id])
    name = assignment.name
    FileUtils.rm_rf @user_root.join('homework', assignment.id.to_s)
    assignment.destroy
    flash[:success] = "#{name} has been successfully deleted"
    redirect_to '/grading/homework'
  end
end
