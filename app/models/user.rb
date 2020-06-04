class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, length: {is: 10}, allow_blank: true
  validate :date_of_birth_in_the_past
  validates :gender, inclusion: {in: %w[Male Female]}, allow_blank: true
  validates :password, confirmation: true

  def date_of_birth_in_the_past
    return if date_of_birth.blank?
    return if date_of_birth <= Date.today

    errors.add(:date_of_birth, "can't be in the future")
  end
end
