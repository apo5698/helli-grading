require 'securerandom'

class User < ApplicationRecord
  has_secure_password

  has_many :courses, dependent: :destroy
  has_many :assignments, through: :courses

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, confirmation: true, length: { minimum: 6 }, allow_blank: true
end
