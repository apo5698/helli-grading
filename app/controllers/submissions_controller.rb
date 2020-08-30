class SubmissionsController < ApplicationController
  def index; end

  def upload
    zip_file = params[:zip]
    if zip_file.nil?
      flash[:error] = 'Upload failed (no file chosen)'
    else
      course_id = params[:course_id]
      begin
        count = ActiveStorageUtil.upload(zip_file, course_id, @assignment.id).count
        flash[:success] = "Successfully uploaded #{zip_file.original_filename} (#{count} file#{'s' if count > 1})."
      rescue StandardError => e
        flash[:error] = "Upload failed (#{e})"
      end
    end
    redirect_back(fallback_location: '')
  end

  def destroy
    Submission.destroy(params[:id])
    flash[:success] = 'Submission deleted.'
    redirect_back(fallback_location: '')
  end

  def download_all
    zip = ActiveStorageUtil.download_submission_zip(@course, @assignment)
    begin
      send_data(File.read(zip.path), filename: File.basename(zip), type: 'application/zip', disposition: 'attachment')
    ensure
      zip.close
      zip.unlink
    end
  end

  def destroy_selected
    selected = params[:submissions]&.select { |_, v| v.to_i == 1 }
    if selected.nil?
      flash[:error] = 'No submission found.'
    elsif selected.empty?
      flash[:error] = 'No submission selected.'
    else
      selected.each { |k, _| Submission.destroy(k) }
      flash[:success] = 'Selected submission(s) deleted.'
    end
    redirect_back(fallback_location: '')
  end

  private def set_variables
    super
    @submissions = Submission.where(assignment_id: params[:assignment_id])
  end
end
