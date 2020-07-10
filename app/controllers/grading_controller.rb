class GradingController < ApplicationController
  def index
    @rubric_items = RubricItem.where(rubric_id: @assignment.rubric.id)
  end

  def run;
  end

  def run_all;
  end

  def respond;
  end
end
