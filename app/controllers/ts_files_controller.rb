class TsFilesController < ApplicationController
  def index
    ts_file = TsFile.find_by(assignment_id: @assignment.id)
    ts_file ||= TsFile.new
    @ts_files = ts_file.files
  end

  def upload
    files = params[:files]
    if files.blank?
      flash[:error] = 'No file chosen.'
    else
      files.each do |file|
        flash[:info] = TsFilesHelper.upload(file, @assignment.id)
      end
      flash[:success] = "Successfully uploaded #{files.count} #{'file'.pluralize(files.count)}."
    end
    redirect_back(fallback_location: '')
  end

  private
end
