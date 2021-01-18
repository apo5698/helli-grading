# frozen_string_literal: true

require 'zip'

# Represents an assignment. It can be either an exercise or a project.
class Assignment < ApplicationRecord
  ################
  # Associations #
  ################

  belongs_to :course

  has_many :programs, dependent: :destroy

  has_many :participants, dependent: :destroy
  has_many :submissions, through: :participants

  has_one :rubric, dependent: :destroy
  has_many :rubric_items, through: :rubric, class_name: 'Rubrics::Item::Base', source: :items
  has_many :grade_items, through: :rubric_items

  ###############
  # Attachments #
  ###############

  has_many_attached :input_files

  ###############
  # Validations #
  ###############

  validates :name, :category, presence: true
  validates :name, uniqueness: { scope: %i[course_id] }

  #############
  # Callbacks #
  #############

  ################
  # Enumerations #
  ################

  enum category: {
    exercise: 'Exercise',
    project: 'Project'
  }

  amoeba do
    enable
    exclude_association :rubric
    exclude_association :grade_items
    exclude_association :participants
  end

  # Raised when the program to add already exists.
  class ProgramExists < Helli::ApplicationError
    def initialize(program)
      super("#{program} already exists.")
    end
  end

  def to_s
    name
  end

  def dup_to(to, course_copy = false)
    # assignment object itself
    new_assignment = amoeba_dup
    new_assignment.course_id = to.to_i
    if course_copy
      new_assignment.description = ''
    else
      new_assignment.name = "Copy of #{name}"
      i = 2
      until valid?
        new_assignment.name = "Copy of #{name} #{i}"
        i += 1
      end
      new_assignment.description = "Copied from course #{course}"
    end
    new_assignment.save

    # rubric (amoeba_dup doesn't work)
    new_rubric = Rubric.create(assignment_id: new_assignment.id)
    rubric_items.each do |ri|
      new_ri = ri.dup
      new_ri.rubric_id = new_rubric.id
      new_ri.save
      ri.rubric_criteria.each do |rc|
        new_rc = rc.dup
        new_rc.rubric_item_id = new_ri.id
        new_rc.save
      end
    end
  end

  def export_grades
    gi_max = rubric_items.sum(&:maximum_points)
    zybooks_scores = zybooks_scale.keys

    participants.each do |p|
      gi_total = p.grade_items.sum(&:grade)
      p.update(program_total: gi_total)

      moodle_max = p.grade.maximum_grade
      program_max = moodle_max * grades_scale[:program] / 100.0
      zybooks_max = moodle_max * grades_scale[:zybooks] / 100.0

      program_partial = program_max * (gi_total / gi_max)
      zybooks_percentage = zybooks_scale[zybooks_scores.select { |score| (p.zybooks_total || 0) >= score }[0]] || 0
      zybooks_partial = zybooks_max * (zybooks_percentage / 100.0)

      p.grade.update(grade: program_partial + zybooks_partial + (p.other_total || 0))
    end
  end

  def export_feedbacks
    participants.each do |p|
      feedback = []
      p.grade_items.each do |gi|
        feedback << gi.to_s + gi.feedback if gi.feedback.present?
      end

      if grades_scale[:zybooks].positive?
        moodle_max = p.grade.maximum_grade
        zybooks_max = moodle_max * grades_scale[:zybooks] / 100.0
        zybooks_percentage = zybooks_scale[zybooks_scores.select { |score| (p.zybooks_total || 0) >= score }[0]] || 0
        zybooks_partial = zybooks_max * (zybooks_percentage / 100.0)
        feedback << "[zyBooks]Total: #{p.zybooks_total || 0} => #{zybooks_partial}"
      end

      p.grade.update(feedback_comments: feedback.join('; '))
    end
  end

  # percentage = 1 - number_of_unresolved / total
  def percentage_complete
    return 0 if grade_items.empty?

    unresolved = grade_items.where(status: %w[Inactive Unresolved])
    ((1 - unresolved.count.to_f / grade_items.count) * 100).to_i
  end
end
