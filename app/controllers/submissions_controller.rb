class SubmissionsController < AssignmentsViewController
  def index
    link = course_assignment_path(@course, @assignment)
    messages = []

    unless @has_program
      messages << 'No programs found, '\
      "#{helpers.link_to 'add a program', link}"
    end

    unless @has_grades_uploaded
      messages << 'No participant found, '\
      "#{helpers.link_to 'upload the grade worksheet', link}"
    end

    flash_errors messages
  end

  def create
    zip_file = params[:zip]

    if zip_file.nil?
      flash.alert = 'Upload failed (no file chosen).'
      return
    end

    count = Helli::Attachment.upload_moodle_zip(zip_file, @assignment).count
    flash.notice = "Successfully uploaded #{zip_file.original_filename} (#{count} file#{'s' if count > 1})."
  rescue Helli::StudentNotParticipated => e
    flash.alert = "Student #{e.message} does not participate in this assignment. Please check the submissions file."
  ensure
    redirect_back fallback_location: { action: :index }
  end

  def destroy
    if params[:id].present?
      # single file
      Helli::Attachment.delete_by_id(params[:id])
      flash.notice = 'Submission deleted.'
    else
      # multiple files
      selected = params.require(:participants).permit!.to_h
                       .map { |k, v| { k.to_i => v.to_i == 1 } }.reduce(:merge) # { id(int): selected?(boolean) }
                       .select { |_, v| v }.keys # selected ids
      raise 'No participant selected.' if selected.empty?

      selected.each { |id| Participant.find(id).files.purge }
      flash.notice = 'Selected submissions deleted.'
    end

    redirect_back fallback_location: { action: :index }
  end

  def download_all
    zip = Helli::Attachment.download_submission_zip(@course, @assignment)
    send_data(File.read(zip.path), filename: File.basename(zip), type: 'application/zip', disposition: 'attachment')
  ensure
    zip.close
    zip.unlink
  end
end
