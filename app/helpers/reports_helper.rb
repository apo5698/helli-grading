module ReportsHelper
  def self.read(attachment)
    return nil unless attachment.attached?

    path = ActiveStorageUtil.download_one_to_temp('gradesheets', attachment, attachment)
    CSV.parse(File.open(path), headers: true)
  end

  def self.export(assignment, csv, col_email, col_grade, col_feedback, max_grade)
    export_csv = csv
    export_filename = assignment.gradesheet_import.filename.to_s.sub('.csv', '_export.csv')
    rubric_items = assignment.rubric.rubric_items

    export_csv.each do |row|
      if row['Last modified (submission)'] == '-'
        row[col_grade] = 0
        row[col_feedback] = 'No submission.'
        next
      end

      grading_items = []
      original_total = 0.0
      rubric_items.each do |ri|
        grading_items << GradingItem.find_by(rubric_item_id: ri.id, student_id: Student.find_by(email: row[col_email]))
        original_total += ri.points
      end

      grade = grading_items.sum(&:points_received)
      grade *= max_grade.to_f / original_total unless max_grade.blank?
      grade = grade.to_i if grade == grade.to_i

      row[col_grade] = grade
      row[col_feedback] = grading_items.collect(&:status_detail).join("\n").strip
    end

    path = Rails.root.join('tmp', 'storage', 'gradesheets')
    FileUtils.mkdir_p(path)
    path = path.join(export_filename)
    CSV.open(path, 'wb') do |c|
      c << header(csv)
      export_csv.each do |row|
        c << row
      end
    end
    ActiveStorageUtil.upload(assignment.gradesheet_export, path)
  end

  def self.header(csv)
    csv.nil? ? [] : csv.headers
  end
end