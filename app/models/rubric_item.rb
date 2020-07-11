class RubricItem < ApplicationRecord
  include RubricItemsHelper
  has_many :criterions, dependent: :destroy
  has_many :grading_items, dependent: :destroy

  enum rubric_item_type: ['Checkstyle', 'Inspection', 'Javadoc', 'Student BBT', 'Student WBT',
                          'TS BBT', 'TS WBT', 'Write/Compile/Execute']

  def validate(status = :completed, messages = [])
    status, messages = validate_files(status, messages)
    criterions.each do |criterion|
      status, messages = criterion.validate(status, messages)
    end
    [status, messages]
  end

  def points
    points = 0
    criterions.each do |criterion|
      points += criterion.points if criterion.criterion_type == 'Award' || criterion.criterion_type == 'Self-check'
    end
    points
  end
end
