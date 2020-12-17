class RubricItemsController < AssignmentsViewController
  before_action lambda {
    @title = controller_name.classify.pluralize
    @actions = RubricCriterion.actions.invert
    @criteria = RubricCriterion.criteria.invert
  }

  #  GET /courses/:course_id/assignments/:assignment_id/rubric_items
  def index; end

  #  POST /courses/:course_id/assignments/:assignment_id/rubric_items
  def create
    @rubric = Rubric.find_or_create(@assignment.id)
    puts "我在这里"
    puts params
    @rubric_item = @rubric.create_rubric_item(rubric_item_params)

    flash[:success] = "Rubric item for #{@rubric_item.type} created."
    redirect_back fallback_location: { action: :index }
  end

  #  PUT /courses/:course_id/assignments/:assignment_id/rubric_items/:id (save one)
  #  PUT /courses/:course_id/assignments/:assignment_id/rubric_items     (save all)
  def update
    id = params[:id]

    if id
      rubric_item = RubricItem.find(id)
      rubric_item.update(rubric_item_params.except(:criteria))
      rubric_item.update_criteria(rubric_item_params[:criteria])
      RubricItem.find(id).generate_grade_items
      flash[:success] = "Rubric #{rubric_item} has been updated."
    else
      flash[:error] = 'Not implemented.'
    end

    redirect_back fallback_location: { action: :index }
  end

  def destroy
    Rubric.destroy(params[:id])

    flash[:success] = 'Selected rubric deleted.'
    redirect_back fallback_location: { action: :index }
  end

  def show
    # code here
  end

  def all

  end

  private

  def rubric_item_params
    params.require(:rubric_item).permit!
  end
end
