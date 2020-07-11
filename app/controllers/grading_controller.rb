class GradingController < ApplicationController
  def index
    @rubric_items = RubricItem.where(rubric_id: @assignment.rubric.id)
    @rubric_item = RubricItem.find_by(id: params[:id])
    @rubric_item ||= @rubric_items.first

    @grading_items = GradingItem.where(rubric_item_id: @rubric_item)
    @grading_items = generate_grading_items(@assignment, @rubric_item) if @grading_items.empty? && @rubric_item
  end

  def run;
  end

  def run_all;
  end

  def respond;
  end

  private

  def generate_grading_items(assignment, rubric_item)
    submissions = Submission.where(assignment_id: assignment.id)
    submissions.each do |submission|
      grading_item = GradingItem.create(rubric_item_id: rubric_item.id, submission_id: submission.id,
                                        status: 'Not started yet')
      grading_item.grade
    end
    GradingItem.where(rubric_item_id: rubric_item.id)
  end
end
