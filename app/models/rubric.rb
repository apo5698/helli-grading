# noinspection RubyClassVariableUsageInspection
class Rubric < ApplicationRecord
  belongs_to :assignment
  has_many :rubric_criteria, dependent: :destroy, class_name: 'RubricCriterion'
  has_many :grade_items, dependent: :destroy

  before_save { self.maximum_grade = rubric_criteria.reduce(0) { |sum, c| sum + (c.award? ? c.point : 0) } }

  @@feedbacks = RubricCriterion::FEEDBACKS

  def to_s
    "[#{title}](#{primary_file || '?'})"
  end

  def generate_grade_items
    return if grade_items.present?

    assignment.participants.each { |p| GradeItem.create_or_find_by!(participant_id: p.id, rubric_id: id) }
  end

  def update_criteria(criteria)
    rubric_criteria.destroy_all
    criteria.values.each { |c| RubricCriterion.create(c.merge({ rubric_id: id })) }
  end

  # Run grading on a file with options.
  # Returns a Helli::Process and the error count.
  def run(primary_file, secondary_file, options) end
end

# Dir['app/models/rubric/*.rb'].map { |e| File.basename(e, '.rb') }.each { |c| require_dependency 'rubric/' + c }
# require_dependency 'wce'
require_dependency 'rubric/compile'
require_dependency 'rubric/execute'
require_dependency 'rubric/checkstyle'
require_dependency 'rubric/zybooks'
