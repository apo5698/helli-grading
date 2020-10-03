class RubricItem < ApplicationRecord
  has_many :criterions, dependent: :destroy
  has_many :grading_items, dependent: :destroy

  def title; end

  def to_s
    "[#{title}](#{primary_file})"
  end

  def usage; end

  def default_set
    []
  end

  def default_description; end

  def validate(status = :completed, messages = [])
    status, messages = validate_files(status, messages)
    criterions.each do |criterion|
      status, messages = criterion.validate(status, messages)
    end
    [status, messages]
  end

  def validate_files(status, messages)
    if primary_file.blank?
      status = :incomplete
      messages << 'Input file must be provided'
    end
    [status, messages]
  end

  def points
    points = 0.0
    criterions.each do |criterion|
      points += criterion.points if criterion.criterion_type == 'Award' || criterion.criterion_type == 'Self-check'
    end
    points
  end

  def fields
    ['input_file']
  end

  # Grades files in a submission according to the corresponding rubric item.
  # Returns a hash: { :status, :detail, :output, :points }
  def grade(path, options) end
end

require_dependency('wce')
require_dependency('checkstyle')
# require_dependency('document')
# require_dependency('inspection')
# require_dependency('javadoc')
# require_dependency('student_bbt')
# require_dependency('student_wbt')
# require_dependency('ts_bbt')
# require_dependency('ts_wbt')


