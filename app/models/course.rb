class Course < ApplicationRecord
  has_many :assignments, dependent: :destroy
  belongs_to :user

  validates :name, presence: true
  validates :section, presence: true
  validates :section, uniqueness: {scope: %i[name term]}

  SEMESTERS = ['Spring', 'Summer I', 'Summer II', 'Fall'].freeze

  def to_s
    "#{name} (#{section}) #{term![1]} #{term![0]}"
  end

  def term!
    t = term || ENV['CURRENT_TERM'].to_i
    year = 2020 + t / 4
    semester = SEMESTERS[(t - 2020) % 4]
    [year, semester]
  end

  def owner
    User.find(user_id)
  end

  def collaborators
    collaborator_ids.map { |id| User.find(id) }
  end

  def role(uid)
    if uid == user_id
      'Owner'
    elsif uid.in?(collaborator_ids)
      'Collaborator'
    else
      ''
    end
  end

  def self.of(uid)
    Course.where(user_id: uid).or(Course.where("#{uid} = ANY(collaborator_ids)"))
  end

  def percentage_complete
    return 0 if assignments.empty?

    (assignments.sum(&:percentage_complete).to_f / assignments.count).to_i
  end
end
