class Assignment < ApplicationRecord
  serialize :grades_scale, HashSerializer
  serialize :zybooks_scale, HashIntegerKeysSerializer

  belongs_to :course

  has_many :participants, dependent: :destroy
  has_one :rubric, dependent: :destroy
  has_many :rubric_items, through: :rubric, dependent: :destroy
  has_many :grade_items, through: :rubric_items
  has_many :participants
  has_many :grades, through: :participants
  has_many :ts_files, dependent: :destroy

  has_many_attached :input_files

  validates :name, :category, presence: true
  validates :name, uniqueness: { scope: %i[course_id] }

  amoeba do
    enable
    exclude_association :rubric
    exclude_association :grade_items
    exclude_association :grades
    exclude_association :participants
  end

  before_create do
    if exercise?
      self.grades_scale = Helli::Config::Scale.exercise
      self.zybooks_scale = Helli::Config::Scale.zybooks
    elsif project?
      self.grades_scale = Helli::Config::Scale.project
    end
  end

  enum category: {
    exercise: 'Exercise',
    project: 'Project'
  }

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

  # Adds a program to the assignment.
  def add_program(file)
    raise ArgumentError, "#{file} already exists" if programs.include?(file)

    pattern = Helli::Java::FILENAME_REGEXP_STR
    raise ArgumentError, "#{file} does not match pattern #{pattern}" unless file.match(pattern)

    programs << file
  end

  # Deletes a program from the assignment and save.
  def delete_program(file)
    raise ArgumentError, "#{file} does not exist" unless programs.include?(file)

    programs.delete(file)
  end

  def grades_scale
    # used for indexing
    super
  end

  # Sets the grades scale of the assignment. The sum of these values must be 100.
  #
  #   grades_scale = { program = 50, zybooks = 25, other = 25 }
  #     #=> { program: 50, zybooks: 25, other: 25 }
  #
  #   grades_scale = { program = 10, zybooks = 20, other = 30 }
  #     #=> ArgumentError: the sum of values must be 100
  #
  # Although values are all optional, at least one should be provided.
  #
  #   grades_scale = { program = 0 }
  #     #=> ArgumentError: provide at least one value
  #
  # If +other+ is not specified, the sum of +program+ and +zybooks+ will always be 100, no matter
  # one or both values are provided.
  #
  #   grades_scale = { program = 50, zybooks = 50 }
  #     #=> { program: 50, zybooks: 50, other: 0 }
  #
  #   grades_scale = { program = 100 }
  #     #=> { program: 100, zybooks: 0, other: 0 }
  #
  #   grades_scale = { zybooks = 25 }
  #     #=> { program: 75, zybooks: 25, other: 0 }
  def grades_scale=(scale)
    program = scale[:program] || 0
    zybooks = scale[:zybooks] || 0
    other = scale[:other] || 0

    raise ArgumentError, 'provide at least one value' if program.zero? && zybooks.zero? && other.zero?
    raise ArgumentError, 'value must be integer' unless program.is_a?(Integer) && zybooks.is_a?(Integer) && other.is_a?(Integer)
    raise ArgumentError, 'value cannot be negative' if program.negative? || zybooks.negative? || other.negative?

    sum = 100
    if other.zero?
      if program.zero?
        program = sum - zybooks
      elsif zybooks.zero?
        zybooks = sum - program
      end
    end

    raise ArgumentError, "the sum of values must be #{sum}" if program + zybooks + other != sum

    super({ program: program, zybooks: zybooks, other: other })
  end

  def zybooks_scale
    # used for indexing
    super
  end

  # Sets the zyBooks grades scale of the assignment. At least one scale should be provided.
  # The grades must be sorted in the same order as levels.
  #
  #   zybooks_scale = { 90 => 100, 80 => 80 }
  #     #=> { 90 => 100, 80 => 80 }
  #
  #   zybooks_scale = {}
  #     #=> ArgumentError: provide at least one value
  #
  #   zybooks_scale = { 90 => 50, 80 => 60, 70 => 100 }
  #     #=> ArgumentError: grades are not sorted
  def zybooks_scale=(scale)
    raise ArgumentError, 'provide at least one value' if scale.empty?

    scale = scale.map { |k, v| { k.to_i => v.to_i } }.reduce(:merge).sort.reverse.to_h
    raise ArgumentError, 'grades are not sorted' if scale.values.sort.reverse != scale.values

    super(scale)
  end

  # Returns attachments from all participants.
  def attachments
    Participant.joins(:files_attachments).where(assignment_id: id)
  end

  alias submissions attachments

  # Generates students, participants, and grades for current assignment.
  # Records will not be updated if they already exist and with same values.
  def generate_records(worksheet)
    # cannot not use grades.destroy_all here:
    #   ActiveRecord::HasManyThroughCantAssociateThroughHasOneOrManyReflection - Cannot modify
    #   association 'Assignment#grades' because the source reflection class 'Grade' is associated to
    #   'Participant' via :has_one.:
    grades.each(&:destroy)
    participants.destroy_all

    worksheet.each do |row|
      student = Student.create_or_find_by!(
        name: row[:full_name],
        email: row[:email_address]
      )

      participant = Participant.create_or_find_by!(
        assignment_id: id,
        student_id: student.id
      )

      # current grades have been destroyed above so no need to check duplicates here
      Grade.create!(row.merge(participant_id: participant.id))
    end
  end

  def calculate_grades
    gi_max = rubric_items.sum(&:maximum_grade)
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

  def generate_feedbacks
    zybooks_scores = zybooks_scale.keys.map(&:to_i).sort.reverse

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
