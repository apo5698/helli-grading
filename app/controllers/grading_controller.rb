class GradingController < ApplicationController
  def index
    if @rubric_item.nil?
      flash[:error] = 'No rubric specified.'
      redirect_to("/courses/#{@course.id}/assignments/#{@assignment.id}/rubric")
    end
  end

  def run
    if @grading_items.nil?
      flash[:error] = 'No input file specified.'
    else
      options = params.require(:options).permit!.to_h
      @grading_items.each { |item| item.grade(options) }
      flash[:success] = "Grading complete."
    end
    redirect_back(fallback_location: '')
  end

  def run_all; end

  def respond; end

  def reset
    GradingItem.where(rubric_item_id: @rubric_item.id).destroy_all
    flash[:success] = 'Grading status reset.'
    redirect_back(fallback_location: '')
  end

  private

  def generate_grading_items(assignment, rubric_item)
    submissions = Submission.where(assignment_id: assignment.id)
    submissions.each do |submission|
      GradingItem.create(rubric_item_id: rubric_item.id, submission_id: submission.id, status: 'Not started')
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
