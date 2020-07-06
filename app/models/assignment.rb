class Assignment < ApplicationRecord
  has_many :submissions, dependent: :destroy
  belongs_to :rubric, dependent: :destroy

  enum assignment_type: %i[Exercise Project Homework]

  validates :name, presence: true
  validates :course_id, presence: true
  validates :name, uniqueness: { scope: %i[course_id] }

  def to_s
    name
  end
end
