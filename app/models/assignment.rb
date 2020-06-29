class Assignment < ApplicationRecord
  enum assignment_type: %i[Exercise Project Homework]

  validates :name, presence: true
  validates :course_id, presence: true
  validates :name, uniqueness: { scope: %i[course_id] }

end
