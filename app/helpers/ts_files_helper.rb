module TsFilesHelper
  # Creates a TsFile if it does not exist and returns an TsFile object.
  def self.create(assignment_id)
    ts_file = TsFile.find_by(assignment_id: assignment_id)
    ts_file || TsFile.create(assignment_id: assignment_id)
  end

  # create a new TsFile object for each corresponding file to be uploaded
  # files inside a zip will be flattened
  def self.upload(file, assignment_id)
    ts_file = TsFilesHelper.create(assignment_id)
    if file.path.end_with?('.zip')
      dir = ActiveStorageHelper.unzip(file, assignment_id, ts: true)
      entries = Dir.glob(File.join(dir, '**', '*')).select { |f| File.file?(f) }
      entries.each do |e|
        ts_file.files.attach(io: File.open(e), filename: File.basename(e))
      end
      FileUtils.remove_entry_secure(dir)
    else
      ts_file.files.attach(io: File.open(file), filename: file.original_filename)
    end
  end

  def self.has_ts_files(assignment_id)
    !TsFile.find_by(assignment_id: assignment_id).files.empty?
  end
end
