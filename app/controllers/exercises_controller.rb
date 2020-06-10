class ExercisesController < GradingController
  def index
    @assignments = Exercise.all
    @assignment = Exercise.new
  end

  def destroy
    assignment = Exercise.find(params[:id])
    name = assignment.name
    FileUtils.rm_rf @user_root.join('exercises', assignment.id.to_s)
    assignment.destroy
    flash[:success] = "#{name} has been successfully deleted"
    redirect_to '/grading/exercises'
  end
end
