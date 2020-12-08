class GradingController < AssignmentsViewController
  before_action -> { @title = 'Automated Grading' }

  before_action lambda {
    @rubric = Rubric.find(params.require(:id))
    @grade_items = @rubric.grade_items.presence || @rubric.generate_grade_items

    @dependencies ||= Helli::Dependency.public_dependencies
    @status_colors ||= {
      inactive: :light,
      success: :success,
      resolved: :info,
      unresolved: :danger,
      error: :error,
      no_submission: :warning
    }
    @checkstyle_rules = Rubric::Checkstyle::RULES
  }, except: :index

  #  GET /courses/:course_id/assignments/:assignment_id/grading
  def index
    if @submissions.present? && @rubrics.present?
      redirect_to action: :show, id: @assignment.rubrics.first.id
      return
    end

    messages = []

    if @submissions.empty?
      messages << 'No submission uploaded. '\
                  "#{helpers.link_to 'Upload a submission zip file',
                                     course_assignment_submissions_path(@course, @assignment)}".html_safe
    elsif @rubrics.empty?
      messages << 'No rubric specified. '\
                  "#{helpers.link_to 'Create a rubric',
                                     course_assignment_rubrics_path(@course, @assignment)}".html_safe
    end

    flash_errors messages
  end

  #  GET /courses/:course_id/assignments/:assignment_id/grading/:id
  def show
    if @grade_items.blank?
      flash[:error] = 'Rubrics not completed.'
      redirect_back fallback_location: ''
      return
    end

    respond_to do |format|
      format.html { render 'show' }
    end
  end

  #  PUT /courses/:course_id/assignments/:assignment_id/grading/:id
  def update
    if @grade_items.empty?
      flash[:error] = 'The rubric has not been completed. '\
                      "#{helpers.link_to 'Complete',
                                         course_assignment_rubrics_path(@course, @assignment)}.".html_safe
      redirect_back fallback_location: { action: :show }
      return
    end

    options = params.require(:options).permit!.to_h

    threads = []
    @grade_items.each do |item|
      threads << Thread.new { item.run(options) }
    end
    threads.each(&:join)

    respond_to do |format|
      format.js { flash.now[:success] = "Run #{@rubric} complete." }
    end
  end

  #  DELETE /courses/:course_id/assignments/:assignment_id/grading/:id
  def destroy
    id = params.require(:id)
    GradeItem.where(rubric_id: id).destroy_all
    title = Rubric.find(id)

    flash[:success] = "Grading results for #{title} has been reset."
    redirect_back fallback_location: { action: :show }
  end
end
