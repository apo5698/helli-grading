class Assignment < ApplicationRecord
  enum assignment_type: %i[Exercise Project Homework]

  validates :name, presence: true
  validates :course_id, presence: true
  validate :unique_name_in_course

  def unique_name_in_course
    return if Assignment.where(course_id: course_id, name: name).count <= 1

    errors.add(:name, 'has already been taken')
  end
end
