class GradesController < AssignmentsViewController
  def index
    @title = 'Grades'
    @csv_header = Helli::CSV.header(:moodle)
    return unless @assignment.grade_items.any?(&:unresolved?)

    flash.alert = <<~HTML
      There are unresolved grade items.
      #{helpers.link_to 'Resolve', course_assignment_grading_index_path(@course, @assignment)}.
    HTML
  end

  def export

    flash.notice = 'Grades cleared.'
    redirect_back fallback_location: :index
  end

  def destroy
    # rubocop:disable Rails/SkipsModelValidations
    @participants.update_all(grade: nil, feedback_comments: '')

    flash.notice = 'Grades cleared.'
    redirect_back fallback_location: :index
  end
end
