class RubricItemsController < AssignmentsViewController
  #  GET /courses/:course_id/assignments/:assignment_id/rubrics
  def index
    @title = 'Rubrics'
    @actions = Rubrics::Criterion::Base.actions.invert
    @criteria = Rubrics::Criterion::Base.criteria.invert
  end

  #  POST /courses/:course_id/assignments/:assignment_id/rubrics
  def create
    rubric = Rubric.find_or_create_by(assignment_id: @assignment.id)
    @rubric_item = rubric.items.create!(rubric_item_params)

    flash.notice = "Rubric item for #{@rubric_item} created."
    redirect_back fallback_location: { action: :index }
  end

  #  PUT /courses/:course_id/assignments/:assignment_id/rubrics/:id (save one)
  #  PUT /courses/:course_id/assignments/:assignment_id/rubrics     (save all)
  def update
    id = params[:id]

    if id
      rubric_item = Rubrics::Item::Base.find(id)
      criteria = rubric_item_params.delete(:criteria)
      rubric_item.update(rubric_item_params)
      criteria.each { |cid, attributes| Rubrics::Criterion::Base.find(cid.to_i).update!(attributes) }
      # RubricItem.find(id).create_grade_items
      flash.notice = "Rubric #{rubric_item} has been updated."
    else
      flash.alert = 'Save all is not implemented.'
    end

    redirect_back fallback_location: { action: :index }
  end

  #  DELETE /courses/:course_id/assignments/:assignment_id/rubrics/:id
  def destroy
    Rubrics::Item::Base.destroy(params[:id])

    flash.notice = 'Selected rubric deleted.'
    redirect_back fallback_location: { action: :index }
  end

  private

  def rubric_item_params
    params[:rubric_item].permit!
  end
end
