class GradingController < AssignmentsViewController
  before_action lambda {
    @title = 'Automated Grading'
    @rubrics.each(&:generate_grade_items)
    @dependencies = Dependency.public_dependencies

    @status_colors = {
      inactive: :light,
      success: :success,
      resolved: :info,
      unresolved: :danger,
      error: :error,
      no_submission: :warning
    }
  }

  #  GET /courses/:course_id/assignments/:assignment_id/grading
  def index
    if @submissions.empty?
      flash.now[:error] = 'No submission uploaded. '\
                          "#{helpers.link_to 'Upload a submission zip file.',
                                             course_assignment_submissions_path(@course, @assignment)}".html_safe
    elsif @rubrics.empty?
      flash.now[:error] = 'No rubric specified. '\
                          "#{helpers.link_to 'Create a rubric.',
                                             course_assignment_rubrics_path(@course, @assignment)}".html_safe
    end
  end

  #  GET /courses/:course_id/assignments/:assignment_id/grading/:id
  def show
    respond_to do |format|
      format.html { render partial: 'show' }
    end
  end

  #  PUT /courses/:course_id/assignments/:assignment_id/grading/:id
  def update
    id = params.require(:id)
    rubric = Rubric.find(id)
    grade_items = rubric.grade_items
    if grade_items.empty?
      flash[:error] = 'The rubric has not been completed. '\
                      "#{helpers.link_to 'Complete.',
                                         course_assignment_rubrics_path(@course, @assignment)}.".html_safe
    else
      # in case there is no option
      options = params.dig(:options, id)&.permit!&.to_h || {}
      grade_items.each { |item| item.run(options) }
      flash[:success] = "Run #{rubric} complete."
    end

    redirect_back fallback_location: { action: :index }
  end

  #  DELETE /courses/:course_id/assignments/:assignment_id/grading/:id
  def destroy
    id = params.require(:id)
    GradeItem.where(rubric_id: id).destroy_all
    title = Rubric.find(id)

    flash[:success] = "Grading results for #{title} has been reset."
    redirect_back fallback_location: { action: :index }
  end
end
