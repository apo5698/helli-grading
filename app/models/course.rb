class Course < ApplicationRecord
  has_many :assignments

  def unique_course
    Assignment.where(name: name, section: section).count <= 1
  end

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
