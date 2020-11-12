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
    participant.files.select { |f| f.blob.filename == rubric.primary_file }[0] || nil
  end

  # Find the attachment by rubric filename.
  # TODO: Find similar filename if no match found.
  def secondary_file
    participant.files.select { |f| f.blob.filename == rubric.secondary_file }[0] || nil
  end

  # Accepts a series of options and then invokes +run()+ per its rubric type.
  def run(options)
    if participant.grade.no_submission?
      # no submission at all
      gi_result = {
        status: :no_submission,
        feedback: 'No submission'
      }
    elsif primary_file.nil?
      # submitted, but no filename matched
      # TODO: handle filename typo, this is just a temporary solution
      gi_result = {
        status: :unresolved,
        feedback: Helli::Message.resolve_manually('No matched filename')
      }
    else
      # download files
      f_source = Helli::Attachment.download(primary_file, 'java', "participant_#{participant.id}")[0]
      f_test = Helli::Attachment.download(secondary_file, 'java', "participant_#{participant.id}")[0]

      # copy input file
      input_files = rubric.assignment.input_files
      input_files_path = Helli::Attachment.download(input_files, 'java', "participant_#{participant.id}")

      # replace input file name to path
      stdin_data = options.dig(:stdin, :data)
      if stdin_data
        stdin_data = stdin_data.split("\n").map! do |str|
          # find(-> { str }): set default value if cannot found
          input_files_path.find(-> { str }) { |path| File.basename(path) == str }
        end
        # put new stdin_data back
        options[:stdin][:data] = stdin_data.join("\n")
      end

      # { :exitcode, :stdout, :stderr, :error }
      begin
        result = rubric.run(f_source, f_test, options)
      rescue StandardError => e
        msg = e.message
        msg = msg.gsub(f_source, File.basename(f_source)).gsub(f_test, File.basename(f_test)) if Rails.env.production?
        gi_result = {
          status: :unresolved,
          feedback: "AutoResolve failed: #{Helli::Message.resolve_manually(msg)}"
        }
        update!(gi_result)
        return
      end

      source_filename = File.basename(f_source)
      source_file_contents = File.read(f_source)
      exitcode = result[:exitcode]

      # grade_item attributes
      gi_status = :success
      gi_stdout = result[:stdout]
      gi_stderr = result[:stderr]
      gi_error = result[:error]
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
            gi_feedback << format(c.feedback, actual: classname)
          end
        elsif c.compile?
          if exitcode.zero?
            # exit 0 -> can compile -> success!
            gi_grade += c.point
            gi_feedback << 'Success'
          else
            # exit not 0 -> cannot compile -> error!
            gi_status = :error
            gi_feedback << c.feedback
          end
        elsif c.execute?
          if exitcode.zero?
            # exit 0 -> can execute: success
            gi_grade += c.point
            gi_feedback << 'Success'
          elsif gi_stderr.empty? && source_file_contents.include?("System.exit(#{exitcode})")
            # can execute & no stderr -> action_needed!
            gi_status = :unresolved
            gi_feedback << Helli::Message.resolve_manually("No error found, but exits with code #{exitcode}")
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
        exitcode: exitcode,
        error: gi_error
      )

      # hide full file path in production
      if Rails.env.production?
        gi_stdout = gi_stdout.gsub(f_source, File.basename(f_source)).gsub(f_test, File.basename(f_test))
        gi_stderr = gi_stderr.gsub(f_source, File.basename(f_source)).gsub(f_test, File.basename(f_test))
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
    end

    update!(gi_result)
  end
end
