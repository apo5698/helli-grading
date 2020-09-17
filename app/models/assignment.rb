class Assignment < ApplicationRecord
  has_one_attached :gradesheet_import
  has_one_attached :gradesheet_export

  has_many :submissions, dependent: :destroy
  has_many :ts_files, dependent: :destroy

  belongs_to :rubric, dependent: :destroy

  enum assignment_type: %i[Exercise Project Homework]

  validates :name, presence: true
  validates :course_id, presence: true
  validates :name, uniqueness: { scope: %i[course_id] }

  def to_s
    name
  end

  def self.input_files(assignment_id)
    find(assignment_id).expected_input_filenames.split(';')
  end
end
