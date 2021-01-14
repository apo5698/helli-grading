# frozen_string_literal: true

# Grade items are generated from a rubric item, and associated with a participant.
class GradeItem < ApplicationRecord
  attr_accessor :content

  ################
  # Enumerations #
  ################

  enum status: {
    inactive: 'Inactive',
    success: 'Success',
    resolved: 'Resolved',
    unresolved: 'Unresolved',
    error: 'Error',
    no_submission: 'No submission'
  }

  ################
  # Associations #
  ################

  belongs_to :participant
  belongs_to :rubric_item, class_name: 'Rubrics::Item::Base'

  ###############
  # Validations #
  ###############

  # Negative grade does not make sense.
  validates :point, numericality: { greater_than_or_equal_to: 0 }

  #############
  # Callbacks #
  #############

  # Set default status if not specified.
  after_initialize { inactive! if status.nil? }

  # Ask participant to fetch latest grades and feedbacks
  after_save { participant.fetch }

  ###############
  # Delegations #
  ###############

  delegate :<=>, :name, to: :participant
  delegate :to_s, :filename, :maximum_points_possible, to: :rubric_item

  def feedback=(feedback)
    super(Helli::SeparatedString.new(feedback).to_s)
  end

  # Resets the grade item the initial state (empty).
  def reset
    update!({ status: :inactive, stdout: '', stderr: '', error: 0, point: 0, feedback: '' })
  end

  # Returns the attachment with the same filename within its participant's submissions.
  #
  # @return [ActiveStorage::Attachment, nil]
  def attachment
    participant.attachment(rubric_item.filename)
  end

  # Accepts a series of options and then invokes #run per its rubric type.
  #
  # @param [Hash] options
  def run(options)
    # No submission per Moodle grade worksheet.
    if participant.no_submission?
      update!(attributes_preset_for(:no_submission))
      return
    end

    if attachment.nil?
      update!(attributes_preset_for(:no_matched_attachment))
      return
    end

    # Downloading strategy:
    #   1. Download files to a temporary directory
    #   2. Keep them for a period of time (default 4 hours)
    #   3. Delete using cron jobs (sidekiq)
    path = Helli::Attachment.download_one(attachment)
    captures, error_count = rubric_item.run(path, options)

    @content = File.read(path)

    # Assigns attributes before grading
    self.status = :success
    self.stdout = captures[0]
    self.stderr = captures[1]
    self.exitstatus = captures[2].exitstatus
    self.error = error_count
    self.point = 0

    new_feedback = Helli::SeparatedString.new

    rubric_item.criteria.each do |c|
      c.grade_item = self
      new_feedback << c.validate
      # elsif c.criterion.classname?
      #   # search the file for classname
      #   # index 0 ensures result is class name, not subclass name
      #   classname = content.match(/(?<=public class )\w+/)[0]
      #   if classname == File.basename(filename, '.java')
      #     # classname matches -> success!
      #     self.grade += c.point
      #   else
      #     # classname does not match -> error!
      #     self.status = :error
      #     feedback << Helli::String.format(c.feedback, actual: classname)
      #   end
      # elsif c.criterion.execute?
      #   if exitstatus.nil?
      #     self.status = :unresolved
      #     feedback << Helli::String.resolve_manually('Execution expired')
      #   elsif exitstatus.zero?
      #     # exit 0 -> can execute: success
      #     self.grade += c.point
      #     feedback << 'Success'
      #   elsif gi_stderr.empty? && content.include?("System.exit(#{exitstatus})")
      #     # can execute & no stderr -> action_needed!
      #     self.status = :unresolved
      #     feedback << Helli::String.resolve_manually("No error found, but exits with status #{exitstatus}")
      #   else
      #     # exit not 0 -> can/cannot execute & has stderr -> error!
      #     self.status = :error
      #     self.grade -= c.point
      #     feedback << c.feedback
      #   end
      # elsif c.criterion.checkstyle_warning? && gi_error.positive?
      #   # has checkstyle warnings: error!
      #   self.status = :error
      #   self.grade -= c.point * gi_error
      #   feedback << c.feedback
      # end
    end

    self.feedback = new_feedback

    # Grade cannot be negative
    self.point = 0 if point.negative?

    save!
  end

  # An error message indicating that a manual resolution is needed.
  def resolve_manually(msg)
    "#{msg}. Please resolve manually."
  end

  # @param [Symbol] type
  # @return [Hash]
  def attributes_preset_for(type)
    case type
    when :no_submission
      { status: :no_submission, feedback: 'No submission' }
    when :no_matched_attachment
      { status: :unresolved, feedback: resolve_manually('No matched file') }
    else
      raise "Unknown attributes type: #{type}"
    end
  end
end
