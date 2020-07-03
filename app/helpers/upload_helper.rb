require 'zip'

module UploadHelper
  # Extracts the given zip file, creates corresponding students and submissions in database, and
  # then uploads contents to destination based on +config.active_storage.service+
  def self.upload(zip_file, course_id, assignment_id)
    glob = UploadHelper.unzip(zip_file).select { |e| File.directory?(e) }
    glob.sort.each do |e|
      dirname = File.basename(e)
      student_name = dirname.match(/([a-zA-Z]+)\s([a-zA-Z]+).*/)
      student = StudentsHelper.create(student_name[2], student_name[1], course_id)
      submission = SubmissionsHelper.create(student.id, assignment_id)
      Dir.glob(File.join(e, '**', '*')) do |f|
        submission.files.attach(io: File.open(f), filename: File.basename(f))
      end
    end
  end

  def self.delete
  end

  def self.edit
  end

  def self.unzip(file)
    temp_dir = Rails.root.join('tmp', 'storage', file.original_filename)
    FileUtils.mkdir_p(temp_dir)

    Zip::File.open(file) do |zip_file|
      zip_file.each do |f|
        filepath = File.join(temp_dir, f.name)
        FileUtils.mkdir_p(File.dirname(filepath))
        zip_file.extract(f, filepath) unless File.exist?(filepath)
      end
    end

    Dir.glob(temp_dir.join('**', '*'))
  end
end
