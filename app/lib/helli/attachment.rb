require 'zip'

module Helli
  module Attachment
    class << self
      # Extracts a moodle submissions zip file, attaches enclosed files to corresponding participant,
      # and uploads them (see +config/environments/#{Rails.env}/config.active_storage.service+).
      # The attachment with the same name as the file to be uploaded will be overwritten.
      # Returns paths of all uploaded files. Temporary files will be deleted after uploading.
      def upload_moodle_zip(zip, assignment)
        raise ArgumentError if zip.nil? || assignment.nil?

        dest = unzip(zip, assignment.id)

        glob = Dir.glob("#{dest}/**/*")
        dirs = glob.select { |e| File.directory?(e) }
        files = glob.select { |e| File.file?(e) }

        dirs.each do |dir|
          email = File.basename(dir)
          participant = assignment.participants.find { |p| p.email == email }
          model = participant.files
          Dir.glob("#{dir}/**/*").select { |e| File.file?(e) }.each { |f| upload_local(model, f) }
        end

        FileUtils.remove_entry_secure(dest)

        files
      end

      # Extracts a zip file to temporary directory and returns its path.
      def unzip(file, assignment_id, ts: false)
        dest = tmppath('uploads', 'assignments', assignment_id.to_s, ts ? 'ts' : 'src')
        FileUtils.mkdir_p(dest)

        Zip::File.open(file) do |zip_file|
          zip_file.each do |f|
            filepath = f.name
            original_root = filepath.split('/')[0]
            email = original_root.split('__')[1].sub('AT', '@')
            filepath = File.join(dest, filepath.sub(original_root, email))
            FileUtils.mkdir_p(File.dirname(filepath))
            zip_file.extract(f, filepath) unless File.exist?(filepath)
          end
        end

        dest
      end

      def upload_local(model, path, filename: nil)
        model.attach(io: File.open(path), filename: filename || File.basename(path))
      end

      # Deletes the attachment by id. Pass an array of ids if there are multiple to delete.
      def delete_by_id(id)
        Array(id).each { |i| ActiveStorage::Attachment.find(i).purge_later }
      end

      # TODO: refactor
      # Add files to a zip file.
      def self.zip(content_dir, zipfile_path)
        raise 'method under refactoring'

        FileUtils.remove_entry_secure(zipfile_path) if File.exist?(zipfile_path)
        FileUtils.mkdir_p(File.dirname(zipfile_path))
        Zip::File.open(zipfile_path, Zip::File::CREATE) do |zipfile|
          Dir.glob(File.join(content_dir, '**', '*')).each do |s|
            dest = File.join(File.basename(File.dirname(s)), File.basename(s))
            zipfile.add(dest, s)
          end
        end
      end

      # TODO: refactor
      # Downloads submission contents by id from the source based on
      # +config/environments/#{Rails.env}/config.active_storage.service+.
      # All contents will be add into the specified zip file and will be deleted after zip creation.
      # Returns the zip File object.
      def self.download_submission_zip(course, assignment)
        raise 'method under refactoring'

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

      # Downloads attachments to the temp directory and returns their path as array.
      def download(attachments, *dir)
        path = tmppath('downloads', *dir)
        FileUtils.mkdir_p(path)
        list = []

        Array(attachments).each do |a|
          file = File.join(path, a.filename.to_s)
          list << file
          File.open(file, 'wb') { |f| f.write(a.download) }
        end

        list
      end

      def download_one(attachments, *dir)
        download(attachments, *dir)[0]
      end

      ##################
      # Helper methods #
      ##################

      # Returns all directories under given path (recursive).
      def directories(path)
        Dir["#{path}/**/*"].select { |e| File.directory?(e) }
      end

      # Returns all files under given path (recursive).
      def files(path)
        Dir["#{path}/**/*"].select { |e| File.file?(e) }
      end

      # Returns the temporary path.
      def tmppath(*dir)
        File.join('tmp', Array(dir).map(&:to_s))
      end
    end
  end
end