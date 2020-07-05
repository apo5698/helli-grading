class Criterion < ApplicationRecord
  enum criterion_type: ['Award', 'Deduction', 'Award / ea.', 'Deduction / ea.', 'Self-check']
end
