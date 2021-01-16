class Student < ApplicationRecord
  ###############
  # Validations #
  ###############

  validates :name, :email, presence: true
  validates :email, uniqueness: true

  def ==(other)
    email == other.email
  end

  def <=>(other)
    a = name.split(' ')
    b = other.name.split(' ')
    [a[1], a[0]] <=> [b[1], b[0]]
  end

  # Theoretically, school email must be unique.
  # But there is a chance that the moodle grade worksheet can be manually modified by mistake.
  class EmailNotUnique < ActiveRecord::RecordNotFound
    def initialize(name, email)
      existing = Student.find_by(email: email)
      super("The student '#{name}' has a duplicated email address '#{existing.email}' "\
            "to an existing student '#{existing.name}'.")
    end
  end
end
