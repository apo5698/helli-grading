require 'open-uri'
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
          raise Assignment::StudentNotParticipated, email if participant.nil?

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

      # Downloads a file from a URL.
      #
      # @param [String] url downloading URL
      # @param [String] dest destination
      # @param [String] filename custom filename
      # @return [String] download path, or nil if file exists
      def download_from_url(url, dest, filename: nil)
        path = File.join(dest, filename || File.basename(url))
        data = URI.parse(url).open
        # noinspection RubyYardParamTypeMatch
        return if File.exist?(path) && md5(filename: path) == md5(io: data)

        IO.copy_stream(data, path)
        path
      end

      # Calculates MD5 hash from a file.
      #
      # @param [IO] io IO object
      # @param [String] filename filename
      # @return [String] hash value of the MD5 digest
      def md5(io: nil, filename: nil)
        if io
          Digest::MD5.hexdigest(io.read).to_s
        elsif filename
          Digest::MD5.file(filename).hexdigest
        else
          raise ArgumentError
        end
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
