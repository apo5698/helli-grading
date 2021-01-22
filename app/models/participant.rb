# frozen_string_literal: true

# Participants are students who are parts of an assignment.
# Each student can have multiple participants, meaning that they can participate in multiple
# assignments.
# Attributes for an participant is retrieved from a Moodle grade worksheet.
class Participant < ApplicationRecord
  #############
  # Constants #
  #############

  # String values mapping of statuses.
  STATUSES = {
    true => I18n.t('participant.status.submitted'),
    false => I18n.t('participant.status.no_submission')
  }.freeze

  # String values mapping of Moodle grade worksheet header.
  COLUMNS = {
    identifier: 'Identifier',
    full_name: 'Full name',
    email_address: 'Email address',
    status: 'Status',
    grade: 'Grade',
    maximum_grade: 'Maximum Grade',
    grade_can_be_changed: 'Grade can be changed',
    last_modified_submission: 'Last modified (submission)',
    last_modified_grade: 'Last modified (grade)',
    feedback_comments: 'Feedback comments'
  }.freeze

  # Moodle datetime format. For example:
  #   Wednesday, September 23, 2020, 9:00 PM
  MOODLE_INPUT_DATETIME_FORMAT = '%A, %B %e, %Y, %l:%M %p'

  # Moodle datetime format for output (without padding spaces)
  MOODLE_OUTPUT_DATETIME_FORMAT = '%A, %B %e, %Y, %-l:%M %p'

  ################
  # Associations #
  ################

  belongs_to :assignment

  has_many :submissions, dependent: :destroy
  # has_many something_attachments, where "something" is :attachment
  # noinspection RailsParamDefResolve
  has_many :attachment_attachments, through: :submissions, class_name: 'ActiveStorage::Attachment'
  has_many :grade_items, dependent: :destroy

  ###############
  # Validations #
  ###############

  # Do not validate presence of boolean values
  validates :identifier, :full_name, :email_address, :maximum_grade, presence: true

  #############
  # Callbacks #
  #############

  before_save :link_or_create_student

  ###########
  # Aliases #
  ###########

  alias attachments attachment_attachments

  alias_attribute :submitted?, :status

  def no_submission?
    !status
  end

  # Creates a Participant from moodle record.
  # Student will also be created if it is a new participant.
  # Raises a ActiveRecord::RecordInvalid error if validations fail.
  # If the participant exists (by email), its attributes will be updated.
  #
  # @param [Hash, ActionController::Parameters] record a single record from moodle grade worksheet
  # @return [Participant] participant
  def self.create_from_moodle!(assignment_id, record)
    unless Helli::CSV.header_valid?(COLUMNS.values, record.keys)
      raise Helli::ParseError, 'Record contains invalid columns.'
    end

    participant = find_or_initialize_by(
      assignment_id: assignment_id,
      full_name: record[COLUMNS[:full_name]],
      email_address: record[COLUMNS[:email_address]]
    )

    lms = record[COLUMNS[:last_modified_submission]]
    lmg = record[COLUMNS[:last_modified_grade]]

    participant.update!(
      email_address: record[COLUMNS[:email_address]],
      identifier: record[COLUMNS[:identifier]].scan(/\d+/).first.to_i,
      status: STATUSES.key(record[COLUMNS[:status]].split('-')[0].strip),
      grade: record[COLUMNS[:grade]],
      maximum_grade: record[COLUMNS[:maximum_grade]],
      grade_can_be_changed: record[COLUMNS[:grade_can_be_changed]] == 'Yes',
      last_modified_submission: lms == '-' ? nil : DateTime.strptime(lms, MOODLE_INPUT_DATETIME_FORMAT),
      last_modified_grade: lmg == '-' ? nil : DateTime.strptime(lmg, MOODLE_INPUT_DATETIME_FORMAT),
      feedback_comments: record[COLUMNS[:feedback_comments]]
    )

    participant
  end

  # @param [String] name
  # @return [ActiveStorage::Attachment, nil]
  def attachment(name)
    attachments.to_a.find { |a| a.filename == name }
  end

  # Links to or create a Student using name and email properties.
  def link_or_create_student
    # Student may already exists so do not use create_or_find_by!, which raises exception on duplicates.
    student = Student.create_or_find_by(name: full_name, email: email_address)
    self.student_id = student.id
  end

  # Receives and calculates the latest change on grades and feedback comments.
  def fetch
    self.grade = maximum_grade * grade_items.sum(&:point) / grade_items.sum(&:maximum_points)
    self.feedback_comments = if submitted?
                               Helli::SeparatedString.new(grade_items.map { |i| "#{i}: #{i.feedback}" })
                             else
                               STATUSES[false]
                             end
    save!
  end

  # Converts attributes to their original form in grade worksheet.
  def translate_csv_attribute(attribute)
    datetime_format = MOODLE_OUTPUT_DATETIME_FORMAT

    str = {
      identifier: "Participant #{identifier}",
      status: STATUSES[status],
      grade: grade.nil? ? '' : grade,
      grade_can_be_changed: grade_can_be_changed ? 'Yes' : 'No',
      last_modified_submission: last_modified_submission.nil? ? '-' : last_modified_submission.strftime(datetime_format),
      last_modified_grade: last_modified_grade.nil? ? '-' : last_modified_grade.strftime(datetime_format)
    }

    str[attribute] || self[attribute]
  end

  def to_csv
    COLUMNS.reduce([]) { |csv, kv| csv << [kv[1], translate_csv_attribute(kv[0])] }.to_h
  end
end
