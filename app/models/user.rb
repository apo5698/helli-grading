class User < ApplicationRecord
  # Devise's models
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable, :omniauthable

  # Relations
  has_many :courses, dependent: :destroy
  has_many :assignments, through: :courses

  # Validations
  validates :name, presence: true
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true

  # User's role
  enum role: {
    admin: 'Admin',
    instructor: 'Instructor',
    ta: 'Teaching assistant',
    student: 'Student'
  }

  # Returns user's name.
  #
  # @return [String] name
  def to_s
    name
  end
end
