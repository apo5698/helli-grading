class ExercisesController < GradingController
  def index
    super(Object.const_get('Exercise'))
  end

  def new
    super(Object.const_get('Exercise'))
  end

  def destroy
    super
    remove_subdirectories @user_root.join('exercises', @id.to_s)
  end

  private

  def assignment_params
    params.require(:exercise).permit(:name, :type, :term,
                                     :course, :section, :description)
  end
end
