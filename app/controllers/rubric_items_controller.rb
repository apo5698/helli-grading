class RubricItemsController < ApplicationController
  def create
    RubricItem.create(rubric_id: @assignment.rubric.id, rubric_item_type: params[:rubric_item][:rubric_item_type],
                      seq: params[:rubric_item][:seq])
    redirect_back(fallback_location: '')
  end

  def update
    rubric_item = RubricItem.find(params[:id])
    rubric_item.update_attributes(rubric_item_params)
    Criterion.where(rubric_item_id: rubric_item.id).destroy_all
    criteria_params.each_value { |v| Criterion.create(v.merge({rubric_item_id: rubric_item.id})) }
    flash[:success] = "Rubric item ##{rubric_item.seq} has been updated."
    redirect_back(fallback_location: '')
  end

  def destroy
    RubricItem.destroy(params[:id])
    flash[:success] = 'The rubric has been updated.'
    redirect_back(fallback_location: '')
  end

  private

  def rubric_item_params
    params.require(:rubric_item).permit(:description, :primary_file, :secondary_file,
                                        :tertiary_file, :seq)
  end

  def criteria_params
    rip = params.require(:rubric_item).permit!
    rip[:criteria]
  end
end
