class Rubric < ApplicationRecord
  belongs_to :assignment
  has_many :rubric_items, dependent: :destroy
  has_many :rubric_criteria, through: :rubric_items, class_name: 'RubricCriterion'

  amoeba do
    enable
  end

  def self.find_or_create(assignment_id)
    rubric = Rubric.find_by(assignment_id: assignment_id)
    rubric ||= Rubric.create(assignment_id: assignment_id)
  end

  def create_rubric_item(rubric_item_params)
    RubricItem.create(rubric_item_params.merge(rubric_id: id))
  end
end
