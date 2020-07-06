class RubricsController < ApplicationController
  def index;
  end

  def show_published;
  end

  def destroy_published;
  end

  def adopt;
  end

  def show
    @rubric = @assignment.rubric
    unless @rubric
      @rubric = Rubric.create(name: "#{@assignment} rubric", visibility: false, user_id: session[:user_id])
      @assignment.rubric = @rubric
      @assignment.save
    end

    @rubric_items = RubricItem.where(rubric_id: @rubric.id)
  end
end
