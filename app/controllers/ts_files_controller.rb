class TsFilesController < AssignmentsViewController
  before_action lambda {
    flash[:error] = 'Not implemented.'
    redirect_back fallback_location: { controller: :assignments }
  }

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
end
