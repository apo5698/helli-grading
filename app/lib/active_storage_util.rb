module ActiveStorageUtil
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
  def self.unzip(file, assignment_id, ts: false)
    temp_dir = Rails.root.join('tmp', 'storage', assignment_id.to_s, ts ? 'ts' : 'src')
    FileUtils.mkdir_p(temp_dir)
    Zip::File.open(file) do |zip_file|
      zip_file.each do |f|
        moodle_id = f.name.split('/')[0]
        filepath = File.join(temp_dir, f.name.sub(moodle_id, SubmissionsHelper.rename_moodle_id(moodle_id)))
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
  # Returns paths of all uploaded files.
  def self.upload(zipfile, course_id, assignment_id)
    dir = unzip(zipfile, assignment_id)
    entries = Dir.glob(dir.join('**')).sort
    entries.each do |e|
      student_name = File.basename(e).split(' ')
      next if student_name.nil?

      student = StudentsHelper.create(student_name[0], student_name[1], course_id)
      submission = SubmissionsHelper.create(student.id, assignment_id)
      Dir.glob(File.join(e, '**', '*')).select { |f| File.file?(f) }.each do |g|
        submission.files.attach(io: File.open(g), filename: File.basename(g))
      end
    end

    files = Dir.glob(dir.join('**', '*')).select { |f| File.file?(f) }
    FileUtils.remove_entry_secure(dir)
    files
  end

  # Downloads submission contents by id from the source based on
  # +config/environments/#{Rails.env}/config.active_storage.service+.
  # All contents will be add into the specified zip file and will be deleted after zip creation.
  # Returns the zip File object.
  def self.download_submission_zip(course, assignment)
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

  # Returns the path of where the attachment will be downloaded.
  def self.download_dir(attachment_id)
    Rails.root.join('tmp', 'storage', attachment_id.to_s)
  end

  # Downloads one attachment to temp directory and returns its path.
  def self.download_one(attachment)
    path = File.join(download_dir(attachment.id), attachment.filename.to_s)
    return path if File.exist?(path)

    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, 'wb') { |f| f.write(attachment.download) }
    path
  end

  # Downloads multiple attachments to temp directory and returns their paths.
  def self.download_multiple(attachments)
    paths = []
    attachments.each do |a|
      path = download_dir(a.id)
      FileUtils.mkdir_p(path)
      file_path = File.join(path, a.filename.to_s)
      next if File.exist?(file_path)

      File.open(file_path, 'wb') do |f|
        f.write(a.download)
      end
      paths << file_path
    end

    paths
  end
end