require 'csv'

class ReportsController < ApplicationController
  def index; end

  def upload
    gradesheet = params[:gradesheet]
    if gradesheet.nil?
      flash[:error] = 'Upload failed (no file chosen).'
    else
      ActiveStorageUtil.upload(@assignment.gradesheet_import, gradesheet, gradesheet.original_filename)
      flash[:success] = "Successfully uploaded #{gradesheet.original_filename}."
    end

    redirect_back(fallback_location: '')
  end

  def delete
    filename = @assignment.gradesheet_import.filename.to_s

    begin
      @assignment.gradesheet_import.purge
      @assignment.gradesheet_export.purge
      flash[:success] = "Successfully deleted #{filename}."
    rescue StandardError
      flash[:error] = 'Delete failed (no file uploaded).'
    end

    redirect_back(fallback_location: '')
  end

  def export
    columns = params[:column]
    if columns.values.include?(nil)
      flash[:error] = 'Empty column(s).'
    elsif columns.values.uniq.length != 3
      flash[:error] = 'Column should be unique.'
    else
      @csv_export = ReportsHelper.export(@assignment, @csv_import,
                                         columns[:email_address], columns[:grade], columns[:feedback_comments],
                                         params[:max])
      flash[:success] = 'Export successfully.'
    end

    redirect_back(fallback_location: '')
  end

  def download
    send_data(@assignment.gradesheet_export.download,
              filename: @assignment.gradesheet_export.filename.to_s,
              type: 'text/csv')
  end

  private def set_variables
    super
    @csv_import = ReportsHelper.read(@assignment.gradesheet_import)
    @csv_export = ReportsHelper.read(@assignment.gradesheet_export)
  end
end
