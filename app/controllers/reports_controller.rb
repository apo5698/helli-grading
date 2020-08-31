require 'csv'

class ReportsController < ApplicationController
  def index; end

  def upload
    gradesheet = params[:gradesheet]
    if gradesheet.nil?
      flash[:error] = 'Upload failed (no file chosen).'
    else
      @assignment.gradesheet.attach(gradesheet)
      flash[:success] = "Successfully uploaded #{gradesheet.original_filename}."
    end

    redirect_back(fallback_location: '')
  end

  def delete
    gradesheet = @assignment.gradesheet
    if gradesheet.nil? || !@assignment.gradesheet.attached?
      flash[:error] = 'Delete failed (no file uploaded).'
    else
      filename = gradesheet.filename.to_s
      gradesheet.purge
      flash[:success] = "Successfully deleted #{filename}."
    end

    redirect_back(fallback_location: '')
  end

  def export
    name = params[:setting][:name]
    grade = params[:setting][:grade]
    feedback = params[:setting][:feedback]

    if name.nil? || grade.nil? || feedback.nil?
      flash[:error] = "Columns setting incomplete."
    # elsif name == grade || name == feedback || grade == feedback
    #   flash[:error] = "Column must be unique."
    else
      file = ReportsHelper.export(@assignment, @csv_in, name, grade, feedback)
      flash[:info] = File.read(file)
    end

    redirect_back(fallback_location: '')
  end

  private def set_variables
    super
    @csv_in = ReportsHelper.read(@assignment.gradesheet)
    @csv_out = @csv_in
  end
end
