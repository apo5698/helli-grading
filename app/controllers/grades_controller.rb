class GradesController < AssignmentsViewController
  before_action lambda {
    @grades_scale = @assignment.grades_scale
    @zybooks_scale = @assignment.zybooks_scale
    @csv_header = Helli::CSV.header(:moodle)
  }

  # Downloads grades as a csv file.
  #  GET /courses/:course_id/assignments/:assignment_id/grades/new
  def new
    grades = @grades.map do |g|
      g.attributes.symbolize_keys
       .except(:id, :participant_id, :created_at, :updated_at)
       .map { |k, _| { k => g.csv_string(k) } }.reduce(:merge)
    end

    csv = Helli::CSV.write(grades, @csv_header.values)

    send_data(
      csv,
      filename: "AGSExport_Grades-#{@course}-#{@assignment}.csv",
      type: 'text/csv',
      disposition: :attachment
    )
  end

  # Upload grade worksheet.
  #  POST /courses/:course_id/assignments/:assignment_id/grades
  def create
    begin
      worksheet = Helli::CSV.parse(params[:_json], :moodle)
      @assignment.generate_records(worksheet)
      flash.notice = "Moodle grade worksheet uploaded (#{params[:_json].length} participants)."
    rescue StandardError => e
      flash.alert = e.message
    end

    redirect_back fallback_location: { action: :show }
  end

  #  POST /courses/:course_id/assignments/:assignment_id/grades/zybooks
  def zybooks
    if @participants.empty?
      flash.alert = 'Moodle grade worksheet is not uploaded.'
      return
    end

    data = Helli::CSV.parse(params[:_json], :zybooks)
    data.each do |d|
      student = Student.find_by(email: d[:email])
      # safe navigator: a student may drop so +Student+ could be +nil+
      @participants.find_by(student_id: student.id)&.update!(zybooks_total: d[:total]) if student
    end

    flash.notice = 'zyBooks activity report uploaded.'
  rescue Helli::ParseError => e
    flash.alert = e.message
  ensure
    redirect_back fallback_location: { action: :show }
  end

  def show; end

  #  DELETE /courses/:course_id/assignments/:assignment_id/grades
  def destroy
    # RuboCop: Avoid using `update_all` because it skips validations.
    # But we're clearing grades so it's fine :)
    @grades.update_all(grade: nil, feedback_comments: nil)

    flash.notice = 'All grades have been cleared.'
    redirect_back fallback_location: { action: :index }
  end

  #  PUT /courses/:course_id/assignments/:assignment_id/grades
  def update
    # check if all grade items have been resolved
    if @assignment.grade_items.any?(&:unresolved?)
      flash.alert = 'There are unresolved grade results. '\
        "#{helpers.link_to 'Resolve.',
                           course_assignment_grading_index_path(@course, @assignment)}".html_safe
      redirect_back fallback_location: { action: :index }
      return
    end

    grades_scale = params.require(:grades_scale).transform_values(&:to_i).permit!.to_h

    # check if percentage values are valid
    if grades_scale.values.sum != 100
      flash.alert = 'Sum of percentage must be 100%.'
      redirect_back fallback_location: { action: :index }
      return
    end

    attributes = { grades_scale: grades_scale }
    if @assignment.exercise?
      zybooks_scale = params.require(:zybooks_scale).transform_values(&:to_i).permit!.to_h
      attributes[:zybooks_scale] = zybooks_scale
    end

    @assignment.update!(attributes)
    @assignment.calculate_grades
    @assignment.generate_feedbacks

    msg = "Grades is exported using #{grades_scale[:program]}% for program"
    msg << " and #{grades_scale[:zybooks]}% for zyBooks" if @assignment.exercise?
    flash.notice = msg << '.'

    redirect_back fallback_location: { action: :index }
  end
end
