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

  def super_dup
    # course object itself
    new_course = dup
    new_course.name = "Copy of #{name}"
    i = 2
    until valid?
      new_course.name = "Copy of #{name} #{i}"
      i += 1
    end
    new_course.save
    # copy assignments over
    assignments.each do |a|
      a.dup_to(new_course.id, true)
    end
  end

  def term!(to_add = 0)
    t = (term || current_term) + to_add
    year = 2020 + t / 4
    semester = SEMESTERS[(t - 2020) % 4]
    [year, semester]
  end

  def owner
    User.find(user_id)
  end

  def owner?(user)
    user_id == user.id
  end

  def collaborators
    collaborator_ids.map { |id| User.find(id) }
  end

  def permitted_users(user_on_top = nil)
    [user_on_top, owner].uniq + collaborators.keep_if { |c| c != user_on_top }
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

  def percentage_complete
    return 0 if assignments.empty?

    (assignments.sum(&:percentage_complete).to_f / assignments.count).to_i
  end

  def current_term
    ENV['CURRENT_TERM'].to_i
  end

  def self.of(uid)
    Course.where(user_id: uid).or(Course.where("#{uid} = ANY(collaborator_ids)"))
  end
end
