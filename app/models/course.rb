class Course < ApplicationRecord
  has_many :assignments, dependent: :destroy

  validates :name, presence: true
  validates :section, presence: true
  validates :section, uniqueness: { scope: %i[name term] }

  SEMESTERS = ['Spring', 'Summer I', 'Summer II', 'Fall'].freeze

  def to_s
    "#{name} (#{section}) #{term![1]} #{term![0]}"
  end

  def term!
    year = 2020 + term / 4
    semester = SEMESTERS[(term - 2020) % 4]
    [year, semester]
  end
end
