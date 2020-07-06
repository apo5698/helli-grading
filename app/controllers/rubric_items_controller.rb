class RubricItemsController < ApplicationController
  def create
    RubricItem.create(rubric_id: @assignment.rubric.id, rubric_item_type: params[:rubric_item][:rubric_item_type],
                      seq: params[:rubric_item][:seq])
    redirect_back(fallback_location: '')
  end

  def update
    rubric_item = RubricItem.find(params[:id])
    rubric_item.update_attributes(rubric_item_params)
    flash[:success] = "Rubric item ##{rubric_item.seq} has been updated."
    redirect_back(fallback_location: '')
  end

  def destroy_selected;
  end

  private

  def rubric_item_params
    params.require(:rubric_item).permit(:description, :primary_file, :secondary_file,
                                        :tertiary_file)
  end
end
