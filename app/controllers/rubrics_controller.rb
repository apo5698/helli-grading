class RubricsController < ApplicationController
  def index; end

  def show_published; end

  def destroy_published; end

  def adopt; end

  def show
    @rubric = @assignment.rubric

    @rubric_items = RubricItem.where(rubric_id: @rubric.id)
  end
end
