class GradingItem < ApplicationRecord
  # SUCCESS = 'Success'
  # ERROR = 'Error'
  # NOT_STARTED = 'Not started'
  # ACTION_NEEDED = 'Action needed'

  include GradingHelper

  enum status: [ACTION_NEEDED = 'Action needed',
                ERROR = 'Error',
                NO_SUBMISSION = 'No submission',
                NOT_STARTED = 'Not started',
                SUCCESS = 'Success']

  belongs_to :submission
  belongs_to :rubric_item

  # Result has the structure of { :status, :detail, :output }
  def grade(options)
    filename = rubric_item.primary_file
    attachment = submission.files.find { |f| f.filename.to_s == filename }
    if attachment.nil?
      files = submission.files.map { |f| f.filename.to_s }
      result = { status: GradingItem::NO_SUBMISSION, detail: "'#{filename}' not found.\n\n"\
                                                             "[Submitted files]\n"\
                                                             "#{files.join("\n")}",
                 output: '', points: 0 }
    else
      file_path = ActiveStorageUtil.download_one(attachment)
      result = rubric_item.grade(file_path, options)

      self.filename = File.basename(file_path)
      self.file_content = File.read(file_path)
    end

    self.status = result[:status]
    self.status_detail = result[:detail]
    self.output = result[:output]
    self.points_received = result[:points]
    self.error_count = result[:error_count]
    self.save
  end
end
