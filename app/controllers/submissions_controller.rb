class SubmissionsController < ApplicationController
  def index
    @submissions = Submission.where(assignment_id: params[:assignment_id]).sort_by(&:student)
  end

  def upload
    zip_file = params[:zip]
    if zip_file.nil?
      flash[:error] = 'No file selected.'
    else
      course_id = params[:course_id]
      UploadHelper.upload(zip_file, course_id, @assignment.id)
      flash[:success] = "Successfully uploaded #{zip_file.original_filename}."
    end
    redirect_back(fallback_location: '')
  end

  def replace; end

  def download; end

  def destroy
    begin
      Submission.destroy(params[:id])
      flash[:info] = 'Submission deleted.'
    rescue StandardError => e
      flash[:error] = e
    end
    redirect_back(fallback_location: '')
  end
end
