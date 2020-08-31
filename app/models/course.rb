class Course < ApplicationRecord
  has_many :assignments, dependent: :destroy
  has_many :students, dependent: :destroy

  validates :name, presence: true
  validates :term, presence: true
  validates :section, presence: true
  validates :section, uniqueness: { scope: %i[name term] }

  def to_s
    "#{name} (#{section})"
  end

  def self.current_term
    today = Date.today
    year = today.year.to_s
    month = today.month
    semester = if month < 5
                 'Spring'
               elsif month > 5 && month < 8
                 'Summer'
               else
                 'Fall'
               end
    "#{semester} #{year}"
  end
end
