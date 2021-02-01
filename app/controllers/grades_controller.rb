class GradesController < AssignmentsViewController
  before_action -> { @columns ||= Participant::COLUMNS }

  def index
    @title = 'Grades'
    return unless @assignment.grade_items.any?(&:unresolved?)

    flash.alert = <<~HTML
      There are unresolved grade items.
      #{helpers.link_to 'Resolve', course_assignment_grading_index_path(@course, @assignment)}.
    HTML
  end

  def export
    grades = @assignment.participants.reduce([]) { |array, participant| array << participant.to_csv }

    csv_string = CSV.generate(headers: @columns.values, force_quotes: false) do |csv|
      csv << @columns.values
      grades.each do |row|
        csv << row.values
      end
    end

    filename = ['Grades', 'Helli', @course.to_s, @assignment.to_s, @assignment.identifier, '.csv']
    send_data csv_string, filename: filename.join('-'), type: 'text/csv'
  end

  def destroy
    # rubocop:disable Rails/SkipsModelValidations
    @participants.update_all(grade: nil, feedback_comments: '')

    flash.notice = 'Grades cleared.'
    redirect_back fallback_location: :index
  end
end
