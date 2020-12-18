class GradeItem < ApplicationRecord
  belongs_to :participant
  belongs_to :rubric

  delegate :to_s, to: :rubric
  delegate :<=>, :name, to: :participant

  # default status if not specified
  after_initialize { inactive! unless status }

  # Precedence: inactive < success < unresolved < resolved < error < no_submission
  enum status: {
    inactive: 'Inactive',
    success: 'Success',
    resolved: 'Resolved',
    unresolved: 'Unresolved',
    error: 'Error',
    no_submission: 'No submission'
  }

  # Find the source file by rubric filename.
  # TODO: Find similar filename if no match found.
  def primary_file
    participant.files.find_by_filename(rubric.primary_file)
  end

  # Find the attachment by rubric filename.
  # TODO: Find similar filename if no match found.
  def secondary_file
    participant.files.find_by_filename(rubric.secondary_file)
  end

  # Downloads all files needed. Returns path of rubric's primary and secondary files.
  def download(*dir)
    # copy input files
    Helli::Attachment.download(rubric.assignment.input_files, *dir)
    [Helli::Attachment.download_one(primary_file, *dir), Helli::Attachment.download(secondary_file, *dir)]
  end

  # Accepts a series of options and then invokes +run()+ per its rubric type.
  def run(options)
    gi_stdout = ''
    gi_stderr = ''
    gi_error = 0
    gi_grade = 0

    if participant.grade.no_submission?
      # no submission per grade worksheet
      gi_status = :no_submission
      gi_feedback = 'No submission'
    elsif primary_file.nil?
      # submitted, but no matched filename
      # TODO: handle filename typo, this is just a temporary solution
      gi_status = :unresolved
      gi_feedback = Helli::Message.resolve_manually('No matched filename')
    else
      # download files
      primary, secondary = download('java', "participant_#{participant.id}")

      begin
        captures, error = rubric.run(primary, secondary, options)
      rescue StandardError => e
        msg = e.message
        gi_result = {
          status: :unresolved,
          feedback: "AutoResolve failed: #{Helli::Message.resolve_manually(msg)}"
        }
        update!(gi_result)
        return
      end

      source_filename = File.basename(primary)
      source_file_contents = File.read(primary)
      exitstatus = captures[2].exitstatus

      # grade_item attributes
      gi_status = :success
      gi_stdout = captures[0]
      gi_stderr = captures[1]
      gi_error = error
      gi_grade = 0
      gi_feedback = []

      rubric.rubric_criteria.each do |c|
        if c.max_point?
          # max points are assigned by default
          gi_grade += c.point
        elsif c.filename?
          # TODO: handle filename typo, this is just a temporary solution
          gi_grade += c.point
        elsif c.classname?
          # search the file for classname
          # index 0 ensures result is class name, not subclass name
          classname = source_file_contents.match(/(?<=public class )\w+/)[0]
          if classname == File.basename(source_filename, '.java')
            # classname matches -> success!
            gi_grade += c.point
          else
            # classname does not match -> error!
            gi_status = :error
            gi_feedback << Helli::Message.format(c.feedback, actual: classname)
          end
        elsif c.compile?
          if exitstatus.zero?
            # exit 0 -> can compile -> success!
            gi_grade += c.point
            gi_feedback << 'Success'
          else
            # exit not 0 -> cannot compile -> error!
            gi_status = :error
            gi_feedback << c.feedback
          end
        elsif c.execute?
          if exitstatus.nil?
            gi_status = :unresolved
            gi_feedback << Helli::Message.resolve_manually("Execution expired")
          elsif exitstatus.zero?
            # exit 0 -> can execute: success
            gi_grade += c.point
            gi_feedback << 'Success'
          elsif gi_stderr.empty? && source_file_contents.include?("System.exit(#{exitstatus})")
            # can execute & no stderr -> action_needed!
            gi_status = :unresolved
            gi_feedback << Helli::Message.resolve_manually("No error found, but exits with status #{exitstatus}")
          else
            # exit not 0 -> can/cannot execute & has stderr -> error!
            gi_status = :error
            gi_grade -= c.point
            gi_feedback << c.feedback
          end
        elsif c.checkstyle_warning? && gi_error.positive?
          # has checkstyle warnings: error!
          gi_status = :error
          gi_grade -= c.point * gi_error
          gi_feedback << c.feedback
        end
      end

      # grade cannot be negative
      gi_grade = 0 if gi_grade.negative?

      # replace variables in feedback to real values
      gi_feedback = Helli::Message.format(
        # TODO: the separator can be set by user
        gi_feedback.join(';'),
        filename: source_filename,
        exitstatus: exitstatus,
        error: gi_error
      )
    end

    # export result
    gi_result = {
      status: gi_status,
      stdout: gi_stdout,
      stderr: gi_stderr,
      error: gi_error,
      grade: gi_grade,
      feedback: gi_feedback
    }
    update!(gi_result)
  end
end
