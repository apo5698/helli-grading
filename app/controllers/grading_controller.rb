class GradingController < AssignmentsViewController
  before_action -> { @title = 'Automated Grading' }

  #  GET /courses/:course_id/assignments/:assignment_id/grading
  def index
    messages = []

    if @submissions.empty?
      messages << 'No submission uploaded. '\
                  "#{helpers.link_to('Upload a submission zip file',
                                     course_assignment_submissions_path(@course, @assignment))}".html_safe
    end

    if @rubric_items.empty?
      messages << 'No rubric specified. '\
                  "#{helpers.link_to('Create a rubric',
                                     course_assignment_rubric_items_path(@course, @assignment))}".html_safe
    end

    flash.alert = messages
  end

  #  DELETE /courses/:course_id/assignments/:assignment_id/grading/:id
  def destroy
    id = params.require(:id)
    GradeItem.where(rubric_item_id: id).destroy_all
    title = Rubrics::Item::Base.find(id)

    flash.notice = "Grading results for #{title} has been reset."
    redirect_back fallback_location: { action: :show }
  end
end
