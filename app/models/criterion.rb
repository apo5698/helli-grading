class Criterion < ApplicationRecord
  include CriterionsHelper

  enum criterion_type: [AWARD = 'Award',
                        AWARD_EACH = 'Award / ea.',
                        DEDUCTION = 'Deduction',
                        DEDUCTION_EACH = 'Deduction / ea.',
                        SELF_CHECK = 'Self-check']

  def validate(status = :completed, messages = [])
    status, messages = validate_points(status, messages)
    status, messages = validate_criterion(status, messages)
    [status, messages]
  end
end
