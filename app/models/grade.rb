class Grade < ApplicationRecord
  include Helli::Adapter

  belongs_to :participant

  validates :identifier, :full_name, :email_address, :status, :maximum_grade, :grade_can_be_changed, presence: true
  validate :grade, if: -> { grade_can_be_changed }

  enum status: {
    submitted: 'Submitted for grading',
    no_submission: 'No submission'
  }

  def self.create_or_update(attributes)
    g = find_by(identifier: attributes[:identifier], email_address: attributes[:email_address])
    if g.nil?
      create(attributes)
    else
      g.update(attributes.except(:identifier).except(:email_address))
    end
  end

  def self.create_or_update_all(attributes)
    attributes.each { |attr| create_or_update(attr) }
  end

  # Converts attributes to their original form in grade worksheet.
  def csv_string(attribute)
    datetime_format = MoodleGradingWorksheetAdapter::DATETIME_FORMAT

    str = {
      identifier: "Participant #{identifier}",
      status: Grade.statuses[status],
      grade_can_be_changed: grade_can_be_changed ? 'Yes' : 'No',
      last_modified_submission: last_modified_submission.nil? ? '-' : last_modified_submission.strftime(datetime_format),
      last_modified_grade: last_modified_grade.nil? ? '-' : last_modified_grade.strftime(datetime_format)
    }

    str[attribute] || self[attribute]
  end
end
