module ReportsHelper
  def self.read(attachment)
    return nil unless attachment.attached?

    path = ActiveStorageUtil.download_one(attachment)
    CSV.parse(File.open(path), headers: true)
  end

  def self.header(csv)
    csv.nil? ? [] : csv.headers
  end

  def self.export(assignment, csv, col_name, col_grade, col_feedback)
    # TODO: implement
    # filename = assignment.gradesheet.filename.to_s.sub('.csv', '_export.csv')
    # grading_items = GradingItem.where(rubric_item_id: RubricItem.find_by(rubric_id: assignment.rubric_id))
  end
end
