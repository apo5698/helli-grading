class GradingItem < ApplicationRecord
  # SUCCESS = 'Success'
  # ERROR = 'Error'
  # NOT_STARTED = 'Not started'
  # ACTION_NEEDED = 'Action needed'

  include GradingHelper

  enum status: { action_needed: 'Action needed',
                 error: 'Error',
                 no_submission: 'No submission',
                 not_started: 'Not started',
                 success: 'Success' }

  belongs_to :submission
  belongs_to :rubric_item

  def meta
    student = Student.find(Submission.find(submission_id).student_id)
    rubric_item = RubricItem.find(rubric_item_id)
    { name: student.to_s, email: student.email, rubric_item: rubric_item, grading_item: self }
  end

  def attachment
    ActiveStorage::Attachment.find(attachment_id)
  end

  def to_s
    meta.to_s
  end

  # Result has the structure of { :status, :detail, :output }
  def grade(options)
    if attachment.nil?
      result = { status: GradingItem.statuses[:no_submission], detail: "File not found", points: 0 }
    else
      file_path = ActiveStorageUtil.download_one_to_temp('submissions', attachment).to_s
      result = rubric_item.grade(file_path, options)
    end

    self.status = result[:status]
    self.status_detail = rubric_item.to_s + result[:detail] + ';'
    self.output = result[:output]
    self.points_received = result[:points]
    self.error_count = result[:error_count]
    self.save
  end
end
