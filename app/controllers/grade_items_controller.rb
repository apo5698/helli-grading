class GradeItemsController < AssignmentsViewController
  before_action lambda {
    @grade_item = GradeItem.find(params[:id])
    @statuses = GradeItem.statuses.invert
  }

  def update
    @grade_item.status = params[:status]
    @grade_item.grade = params[:grade]
    @grade_item.feedback = params[:feedback]
    @grade_item.save!

    flash[:success] = "#{@grade_item.participant.name} #{@grade_item.rubric} updated."
    redirect_back fallback_location: { controller: :grading }
  end

  def edit; end

  def show; end
end
