class GradingItem < ApplicationRecord
  include GradingHelper

  enum status: ['Graded', 'Not started yet', 'Error occurred', 'Action needed']

  belongs_to :submission
  belongs_to :rubric_item

  def grade
    result = rubric_item.grade(submission.files)
    self.status = result.keys.first
    self.status_detail = result.values.first
    self.save
  end
end
