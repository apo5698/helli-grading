class Criterion < ApplicationRecord
  include CriterionsHelper

  enum criterion_type: ['Award', 'Deduction', 'Award / ea.', 'Deduction / ea.', 'Self-check']

  def validate(status = :completed, messages = [])
    status, messages = validate_points(status, messages)
    status, messages = validate_criterion(status, messages)
    [status, messages]
  end
end
