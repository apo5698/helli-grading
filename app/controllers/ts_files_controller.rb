class TsFilesController < ApplicationController
  before_action :set_variables

  def index
    @ts_files = @ts_file.files
  end

  def upload
    files = params[:files]
    if files.blank?
      flash[:error] = 'No file chosen.'
    else
      files.each { |file| TsFilesHelper.upload(file, @assignment.id) }
      flash[:success] = "Successfully uploaded #{files.count} #{'file'.pluralize(files.count)}."
    end
    redirect_back(fallback_location: '')
  end

  def destroy_selected
    selected = params[:files]&.select { |_, v| v.to_i == 1 }
    if selected.nil?
      flash[:error] = 'No file found.'
    elsif selected.empty?
      flash[:error] = 'No file selected.'
    else
      selected.each do |selected_id, _|
        @ts_file.files.find(selected_id).purge
      end
      flash[:success] = 'Selected file(s) deleted.'
    end
    redirect_back(fallback_location: '')
  end

  private

  def set_variables
    super
    @ts_file = TsFilesHelper.create(@assignment.id)
  end
end
