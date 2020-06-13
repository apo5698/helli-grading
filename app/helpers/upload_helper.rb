require 'zip'

module UploadHelper
  # Uploads a single file or multiple files.
  def self.upload(files, dest)
    raise FileHelper::NoFileSelectedError if files.nil?

    if files.is_a? Enumerable
      puts 'FileHelper::upload(multiple)'.magenta.bold
      files.each do |f|
        FileHelper.create file: f, dest: dest
      end
    else
      puts 'FileHelper::upload(single)'.magenta.bold
      FileHelper.create file: files, dest: dest
    end
  end

  # Deletes a single file or multiple files.
  def self.delete(files)
    raise FileHelper::NoFileSelectedError if files.nil? || files.empty?

    if files.is_a? Enumerable
      puts 'FileHelper::delete(multiple)'.magenta.bold
      files.each do |f|
        FileHelper.remove f
      end
    else
      puts 'FileHelper::delete(single)'.magenta.bold
      FileHelper.remove files
    end
  end

  # This is equivalent to FileHelper.delete, but also remove all empty
  # directories.
  def self.delete!(files)
    delete files

    if files.is_a? Enumerable
      puts 'FileHelper::delete!(multiple directories)'.magenta.bold
      files.each do |filepath|
        dirname = File.dirname(filepath)
        FileHelper.remove dirname if Dir.empty?(dirname)
      end
    elsif Dir.empty? File.dirname(files)
      puts 'FileHelper::delete!(single directory)'.magenta.bold
      FileHelper.remove files
    end
  end

  # Extracts a zip file to destination directory. If +from_moodle+ is set
  # to +true+, directories inside this zip file will be renamed from
  #   <last_name> <first_name>__<unity_id>AT<domain>__<submission_id>_assignsubmission_file_
  # to
  #   <first_name> <last_name>
  def self.unzip(zip, dest, from_moodle: false)
    puts 'FileHelper::unzip'.magenta.bold
    FileHelper.create dir: dest

    Zip::File.open(zip) do |zip_file|
      zip_file.each do |f|
        file_path = File.join(dest, f.name)
        if FileHelper.create dir: File.dirname(file_path)
          ApplicationHelper.log_action action: 'extract', from: File.basename(f.name), to: File.dirname(file_path)
        end
        zip_file.extract(f, file_path) unless File.exist?(file_path)
      end
    end

    return unless from_moodle

    puts 'FileHelper::unzip(from_moodle)'.magenta.bold
    Dir.glob(dest.join('**')) do |path|
      name = File.basename(path).split('__')[0].split(' ')
      name[0], name[1] = name[1], name[0]
      FileHelper.rename(path, File.join(File.dirname(path), name.join(' ')))
    end
  end
end
