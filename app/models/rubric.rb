class Rubric < ApplicationRecord
  ################
  # Associations #
  ################

  belongs_to :assignment

  has_many :items, dependent: :destroy, class_name: 'Rubrics::Item::Base'
  has_many :criteria, through: :items

  amoeba do
    enable
  end
end
