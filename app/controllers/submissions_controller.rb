class SubmissionsController < ApplicationController
  def index
    @submissions = Submission.where(assignment_id: params[:assignment_id]).sort_by(&:student)
  end

  def upload
    zip_file = params[:zip]
    if zip_file.nil?
      flash[:error] = 'No file chosen.'
    else
      course_id = params[:course_id]
      SubmissionsHelper.upload(zip_file, course_id, @assignment.id)
      flash[:success] = "Successfully uploaded #{zip_file.original_filename}."
    end
    redirect_back(fallback_location: '')
  end

  def destroy
    Submission.destroy(params[:id])
    flash[:success] = 'Submission deleted.'
    redirect_back(fallback_location: '')
  end

  def download_all
    zip = SubmissionsHelper.download(@course, @assignment)
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
end
