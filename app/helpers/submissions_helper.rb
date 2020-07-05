require 'zip'

module SubmissionsHelper
  # Creates a submission if it does not exist and returns an Submission object.
  def self.create(student_id, assignment_id)
    s = Submission.find_by(student_id: student_id, assignment_id: assignment_id)
    s || Submission.create(student_id: student_id, assignment_id: assignment_id)
  end

  # Add files to a zip file.
  def self.zip(content_dir, zipfile_path)
    FileUtils.remove_entry_secure(zipfile_path) if File.exist?(zipfile_path)
    FileUtils.mkdir_p(File.dirname(zipfile_path))
    Zip::File.open(zipfile_path, Zip::File::CREATE) do |zipfile|
      Dir.glob(File.join(content_dir, '**', '*')).each do |s|
        dest = File.join(File.basename(File.dirname(s)), File.basename(s))
        zipfile.add(dest, s)
      end
    end
  end

  # Extracts a zip file to /tmp/storage and returns the destination directory path.
  def self.unzip(file)
    temp_dir = Rails.root.join('storage', file.original_filename)
    FileUtils.mkdir_p(temp_dir)
    Zip::File.open(file) do |zip_file|
      zip_file.each do |f|
        filepath = File.join(temp_dir, f.name)
        FileUtils.mkdir_p(File.dirname(filepath))
        zip_file.extract(f, filepath) unless File.exist?(filepath)
      end
    end

    temp_dir
  end

  # Extracts the given zip file, creates corresponding students and submissions in database, and
  # then uploads contents to destination based on
  # +config/environments/#{Rails.env}/config.active_storage.service+.
  # Extracted content will be deleted after uploading.
  def self.upload(zipfile, course_id, assignment_id)
    dir = unzip(zipfile)
    entries = Dir.glob(dir.join('**')).sort
    entries.each do |e|
      dirname = File.basename(e)
      student_name = dirname.match(/([a-zA-Z]+)\s([a-zA-Z]+).*/)&.captures
      next if student_name.nil?

      student = StudentsHelper.create(student_name[1], student_name[0], course_id)
      submission = SubmissionsHelper.create(student.id, assignment_id)
      Dir.glob(File.join(e, '**', '*')).select { |f| File.file?(f) }.each do |g|
        submission.files.attach(io: File.open(g), filename: File.basename(g))
      end
    end

    FileUtils.remove_entry_secure(dir)
  end

  # Downloads submission contents by id from the source based on
  # +config/environments/#{Rails.env}/config.active_storage.service+.
  # All contents will be add into the specified zip file and will be deleted after zip creation.
  # Returns the zip File object.
  def self.download(course, assignment)
    submissions = Submission.where(assignment_id: assignment.id)
    zipfile = Tempfile.new(["#{course}_#{assignment}_#{assignment.id}@", '.zip'])
    Dir.mktmpdir do |dir|
      submissions.each do |sub|
        student_path = File.join(dir, sub.student.to_s)
        FileUtils.mkdir_p(student_path)
        sub.files.each do |remote|
          filepath = File.join(student_path, remote.filename.to_s)
          File.open(filepath, 'wb') { |local| local.write(remote.download) }
        end
      end

      zip(dir, zipfile.path)
    end

    zipfile
  end
end
