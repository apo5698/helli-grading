class GradingItem < ApplicationRecord
  include GradingHelper

  enum status: ['Graded', 'Not started yet', 'Error occurred', 'Action needed']

  belongs_to :submission
  belongs_to :rubric_item

  def grade
    rubric_item.grade(submission)
  end
end
