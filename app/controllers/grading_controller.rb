class GradingController < ApplicationController
  def index
    if @rubric_item.nil?
      flash[:error] = 'No rubric specified.'
      redirect_to(controller: :rubrics, action: :show)
      return
    end

    @submissions = Submission.where(assignment_id: params[:assignment_id])
    if @submissions.empty?
      flash[:error] = 'No submission uploaded.'
      redirect_to(controller: :submissions)
    end
  end

  def run
    if @grading_items.empty?
      flash[:error] = 'No submission uploaded.'
      redirect_to(controller: :submissions)
    else
      options = params.require(:options).permit!.to_h


      @grading_items.each { |item| item.grade(options) }
      flash[:success] = "Grading #{RubricItem.find(params[:id])} complete."

      redirect_back(fallback_location: '')
    end
  end

  def reset
    GradingItem.where(rubric_item_id: @rubric_item.id).destroy_all
    flash[:success] = 'Grading status reset.'
    redirect_back(fallback_location: '')
  end

  private

  def generate_grading_items(assignment, rubric_item)
    submissions = Submission.where(assignment_id: assignment.id)
    submissions.each do |submission|
      attachment = submission.files.find { |f| f.filename == rubric_item.primary_file }
      GradingItem.create(rubric_item_id: rubric_item.id,
                         submission_id: submission.id,
                         attachment_id: attachment.nil? ? -1 : attachment.id,
                         student_id: submission.student_id,
                         status: GradingItem.statuses[:not_started])
    end

    GradingItem.where(rubric_item_id: rubric_item.id)
  end

  def set_variables
    super
    @rubric_items = RubricItem.where(rubric_id: @assignment.rubric.id)
    @rubric_item = RubricItem.find_by(id: params[:id] || params[:rubric_id]) || @rubric_items.first
    return if @rubric_item.nil?

    @grading_items = GradingItem.where(rubric_item_id: @rubric_item.id)
    @grading_items = generate_grading_items(@assignment, @rubric_item) if @grading_items.empty? && @rubric_item
  end
end
