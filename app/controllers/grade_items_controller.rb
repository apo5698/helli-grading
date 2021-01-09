class GradeItemsController < AssignmentsViewController
  include GradingHelper

  skip_before_action :verify_authenticity_token, :only => :run

  before_action lambda {
    id = params[:id] || params[:grade_item_id]
    @grade_item = GradeItem.find(id)
    @rubric_item = @grade_item.rubric_item
    @statuses = GradeItem.statuses.invert
  }

  def update
    @grade_item.status = params[:status]
    @grade_item.grade = params[:grade]
    @grade_item.feedback = params[:feedback]
    @grade_item.save!

    flash.notice = "#{@grade_item.participant.name} #{@grade_item.rubric_item} updated."
    redirect_back fallback_location: { controller: :grading }
  end

  def edit; end

  def show; end

  def run
    options = params.require(:options).permit!.to_h

    @grade_item.run(options)
    flash.notice = "Run #{@rubric_item} complete."

    respond_to do |format|
      format.json { render json: react_grading_page_grade_item(@course, @assignment, @rubric_item, @grade_item).to_json }
    end
  end
end
