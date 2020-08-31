class Rubric < ApplicationRecord
  has_many :rubric_items, dependent: :destroy
end
