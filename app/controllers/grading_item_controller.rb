class GradingItemController < ApplicationController
  def update
    @grading_item.status = params[:status]
    @grading_item.points_received = params[:grade]
    @grading_item.status_detail = params[:feedback]
    @grading_item.save

    flash[:success] = "Feedback for #{Student.find(@grading_item.student_id)}(#{@grading_item.rubric_item}) updated."
    redirect_back(fallback_location: '')
  end

  def edit; end

  def show; end

  private def set_variables
    @grading_item = GradingItem.find(params[:id])
  end
end
