class GradesController < AssignmentsViewController
  include Helli::Adapter
  include Helli::Parser

  before_action lambda {
    @grades_scale = @assignment.grades_scale
    @zybooks_scale = @assignment.zybooks_scale
    @csv_header = MoodleGradingWorksheetAdapter.header
  }

  # Downloads grades as a csv file.
  #  GET /courses/:course_id/assignments/:assignment_id/grades/new
  def new
    grades = @grades.map do |g|
      g.attributes.symbolize_keys
       .except(:id, :participant_id, :created_at, :updated_at)
       .map { |k, _| { k => g.csv_string(k) } }.reduce(:merge)
    end

    csv = CSV.write(grades, @csv_header.values)

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
      worksheet = CSV.parse(params[:_json], MoodleGradingWorksheetAdapter)
      @assignment.generate_records(worksheet)
      flash[:success] = "Moodle grade worksheet uploaded (#{params[:_json].length} participants)."
    rescue StandardError => e
      flash[:error] = e.message
    end

    redirect_back(fallback_location: { action: :show })
  end

  #  POST /courses/:course_id/assignments/:assignment_id/grades/zybooks
  def zybooks
    if @participants.empty?
      flash[:error] = 'Moodle grade worksheet not uploaded.'
    else
      begin
        data = CSV.parse(params[:_json], ZybooksActivityReportAdapter)
        data.each do |e|
          # safe navigator: a student may drop so +Student+ could be +nil+
          student_id = Student.find_by(email: e[:email])&.id
          @participants.find_by(student_id: student_id)&.update!(zybooks_total: e[:total]) if student_id
        end
        flash[:success] = 'zyBooks activity report uploaded.'
      rescue StandardError => e
        flash[:error] = e.message
      end
    end

    redirect_back fallback_location: { action: :show }
  end

  def show; end

  #  DELETE /courses/:course_id/assignments/:assignment_id/grades
  def destroy
    @grades.update_all(grade: nil, feedback_comments: nil)

    flash[:success] = 'All grades have been cleared.'
    redirect_back fallback_location: { action: :index }
  end

  #  PUT /courses/:course_id/assignments/:assignment_id/grades
  def update
    # check if all grade items have been resolved
    if @assignment.grade_items.any?(&:unresolved?)
      flash[:error] = 'There are unresolved grade results. '\
        "#{helpers.link_to 'Resolve.',
                           course_assignment_grading_index_path(@course, @assignment)}".html_safe
      redirect_back fallback_location: { action: :index }
      return
    end

    grades_scale = params.require(:grades_scale).transform_values(&:to_i).permit!.to_h

    # check if percentage values are valid
    if grades_scale.values.sum != 100
      flash[:error] = 'Sum of percentage must be 100%.'
      redirect_back fallback_location: { action: :index }
      return
    end

    attributes = { grades_scale: grades_scale }
    if @assignment.exercise?
      zybooks_scale = params.require(:zybooks_scale).transform_values(&:to_i).permit!.to_h
      attributes.merge!(zybooks_scale: zybooks_scale)
    end

    @assignment.update!(attributes)
    @assignment.calculate_grades
    @assignment.generate_feedbacks

    msg = "Grades is exported using #{grades_scale[:program]}% for program"
    msg << " and #{grades_scale[:zybooks]}% for zyBooks" if @assignment.exercise?
    flash[:success] = msg + '.'

    redirect_back fallback_location: { action: :index }
  end
end
