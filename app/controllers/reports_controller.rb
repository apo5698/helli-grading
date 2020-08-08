class ReportsController < ApplicationController
  def index; end

  def upload
    csv = params[:csv]
    if csv.nil?
      flash[:error] = 'Upload failed (no file chosen)'
    else
      @assignment.csv.attach(csv)
      flash[:success] = "Successfully uploaded #{csv.original_filename}."
    end

    redirect_back(fallback_location: '')
  end

  def export_aggregated; end

  def export; end
end
