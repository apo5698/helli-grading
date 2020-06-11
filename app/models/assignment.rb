class Assignment < ApplicationRecord
  validates :name, presence: true
  validates :section, format: { with: /\A\d{3}\z/, message: "should contain exactly 3 digits" }
end
