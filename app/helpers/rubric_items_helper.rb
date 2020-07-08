module RubricItemsHelper
  def validate_files(status, messages)
    types_that_need_secondary_file = ['Student BBT', 'Student WBT', 'TS WBT', 'TS BBT']
    types_that_need_tertiary_file = ['Student BBT', 'TS BBT']

    status = :incomplete if primary_file.blank?
    status = :incomplete if secondary_file.blank? && types_that_need_secondary_file.include?(rubric_item_type)
    status = :incomplete if tertiary_file.blank? && types_that_need_tertiary_file.include?(rubric_item_type)
    messages << 'All files must be provided' if status == :incomplete
    [status, messages]
  end
end
