class GradingItem < ApplicationRecord
  include GradingHelper

  enum status: ['Graded', 'Not started yet', 'Error occurred', 'Action needed']

  belongs_to :submission
  belongs_to :rubric_item

  def grade
    case rubric_item.title
    when 'Checkstyle'
    when 'Inspection'
    when 'Javadoc'
    when 'Student BBT'
    when 'Student WBT'
    when 'TS BBT'
    when 'TS WBT'
    when 'Write/Compile/Execute'
      grade_wce
    else
    end
  end
end
