class Participant < ApplicationRecord
  belongs_to :student
  has_one :grade, dependent: :destroy
  has_many :grade_items, dependent: :destroy
  has_many_attached :files

  delegate :name, :email, to: :student
end
