class GradingController < AssignmentsViewController
  before_action -> { @title = 'Automated Grading' }

  before_action lambda {
    @rubric_item = RubricItem.find(params.require(:id))
    @grade_items = @rubric_item.grade_items.presence || @rubric_item.generate_grade_items
    @status_colors ||= Color.of(:grade_item_status)
  }, except: :index

  #  GET /courses/:course_id/assignments/:assignment_id/grading
  def index
    if @submissions.present? && @rubric_items.present?
      redirect_to action: :show, id: @assignment.rubric_items.first.id
      return
    end

    messages = []

    if @submissions.empty?
      messages << 'No submission uploaded. '\
                  "#{helpers.link_to 'Upload a submission zip file',
                                     course_assignment_submissions_path(@course, @assignment)}".html_safe
    elsif @rubric_items.empty?
      messages << 'No rubric specified. '\
                  "#{helpers.link_to 'Create a rubric',
                                     course_assignment_rubric_items_path(@course, @assignment)}".html_safe
    end

    flash.alert = messages
  end

  #  GET /courses/:course_id/assignments/:assignment_id/grading/:id
  def show
    if @grade_items.blank?
      flash.alert = 'Rubrics not completed.'
      redirect_back fallback_location: ''
      return
    end

    respond_to do |format|
      format.html { render 'show' }
    end
  end

  #  DELETE /courses/:course_id/assignments/:assignment_id/grading/:id
  def destroy
    id = params.require(:id)
    GradeItem.where(rubric_item_id: id).destroy_all
    title = RubricItem.find(id)

    flash.notice = "Grading results for #{title} has been reset."
    redirect_back fallback_location: { action: :show }
  end
end
