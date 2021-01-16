class SubmissionsController < AssignmentsViewController
  def index
    @title = 'Submissions'

    link = course_assignment_path(@course, @assignment)
    messages = []

    unless @has_programs
      messages << 'No programs found, '\
      "#{helpers.link_to 'add a program', link}"
    end

    if @participants.empty?
      messages << 'No participant found, '\
      "#{helpers.link_to 'upload the grade worksheet', link}"
    end

    flash.alert = messages if messages.present?
  end

  #  POST /courses/1/assignments/1/submissions
  def create
    zip = params.require(:zip)
    count = Submission.upload(zip.tempfile.path, @assignment.id).count
    flash.notice = "Successfully uploaded #{zip.original_filename} (#{count} file#{'s' if count > 1})."
  rescue Helli::StudentNotParticipated => e
    flash.alert =
      "Participant #{e.message} is not found in this assignment. Please check the zip file."
  ensure
    redirect_back fallback_location: { action: :index }
  end

  #  DELETE /courses/1/assignments/1/submissions
  #  DELETE /courses/1/assignments/1/submissions/:id
  def destroy
    if params[:id]
      # single file
      Submission.destroy(params.require(:id))
      flash.notice = 'Submission deleted.'
    elsif params[:participants]
      # multiple files
      participants = params.require(:participants)
                           .select { |_, v| v.to_b == true }
                           .keys
                           .map(&:to_i)
      raise 'No participant selected.' if participants.empty?

      Submission.where(participant_id: participants).destroy_all
      flash.notice = 'Submissions of selected participants deleted.'
    end

    redirect_back fallback_location: { action: :index }
  end
end
