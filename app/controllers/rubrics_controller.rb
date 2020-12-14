class RubricsController < AssignmentsViewController
  before_action lambda {
    @title = controller_name.classify.pluralize
    @actions = RubricCriterion.actions.invert
    @criteria = RubricCriterion.criteria.invert
  }

  #  GET /courses/:course_id/assignments/:assignment_id/rubrics
  def index; end

  #  POST /courses/:course_id/assignments/:assignment_id/rubrics
  def create
    @rubric = Rubric.new(assignment_id: @assignment.id)
    @rubric.update!(rubric_params)

    flash[:success] = "Rubric for #{@rubric.type} created."
    redirect_back fallback_location: { action: :index }
  end

  #  PUT /courses/:course_id/assignments/:assignment_id/rubrics/:id (save one)
  #  PUT /courses/:course_id/assignments/:assignment_id/rubrics     (save all)
  def update
    id = params[:id]

    if id
      rubric = Rubric.find(id)
      rubric.update(rubric_params.except(:criteria))
      rubric.update_criteria(rubric_params[:criteria])
      Rubric.find(id).generate_grade_items
      flash[:success] = "Rubric #{rubric} has been updated."
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

  private

  def rubric_params
    params.require(:rubric).permit!
  end
end
