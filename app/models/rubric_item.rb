# noinspection RubyClassVariableUsageInspection
class RubricItem < ApplicationRecord
  belongs_to :rubric
  has_many :rubric_criteria, dependent: :destroy, class_name: 'RubricCriterion'
  has_many :grade_items, dependent: :destroy

  before_save { self.maximum_grade = rubric_criteria.reduce(0) { |sum, c| sum + (c.award? ? c.point : 0) } }

  @@feedbacks = RubricCriterion::FEEDBACKS

  amoeba do
    enable
  end

  def to_s
    "[#{title}](#{primary_file || '?'})"
  end

  def generate_grade_items
    return if rubric_criteria.blank? || grade_items.present?

    rubric.assignment.participants.each { |p| GradeItem.create_or_find_by!(participant_id: p.id, rubric_item_id: id) }
    GradeItem.where(rubric_item_id: id)
  end

  def update_criteria(criteria)
    rubric_criteria.destroy_all
    criteria.values.each { |c| RubricCriterion.create(c.merge({ rubric_item_id: id })) }
  end

  # Run grading on a file with options.
  # Returns a Helli::Process and the error count.
  def run(primary_file, secondary_file, options) end
end

# Dir['app/models/rubric/*.rb'].map { |e| File.basename(e, '.rb') }.each { |c| require_dependency 'rubric/' + c }
# require_dependency 'wce'
require_dependency 'rubric_item/compile'
require_dependency 'rubric_item/execute'
require_dependency 'rubric_item/checkstyle'
require_dependency 'rubric_item/zybooks'
