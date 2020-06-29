class Course < ApplicationRecord
  has_many :assignments

  validates :name, presence: true
  validates :term, presence: true
  validates :section, presence: true
  validates :section, uniqueness: { scope: %i[name term] }

  def to_s
    name + ' (' + section + ')'
  end

  def self.current_term
    today = Date.today
    if today.month <= 6
      'Spring ' + today.year.to_s
    else
      'Fall ' + today.year.to_s
    end
  end
end
