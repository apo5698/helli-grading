# frozen_string_literal: true

require 'open-uri'

module Helli
  # Attachment and file utilities.
  module Attachment
    class << self
      # Downloads attachments to a temporary directory.
      #
      # @param [Submission, ActiveStorage::Attachment] attachments can be one or more
      # @param [Array] entries entry names
      # @return [Array] paths of downloaded attachments
      def download(attachments, *entries)
        dir = File.join(tmpdir, *entries)
        FileUtils.mkdir_p(dir)

        Array(attachments).map do |attachment|
          path = File.join(dir, attachment.filename.to_s)
          File.write(path, attachment.download)
          path
        end
      end

      # Downloads an attachment to a temporary directory.
      #
      # @param [Submission, ActiveStorage::Attachment, nil] attachment an attachment
      # @param [Array] entries entry names
      # @return [String] path of downloaded attachment
      def download_one(attachment, *entries)
        download(attachment, *entries)[0]
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

      # Creates the temporary directory for Helli.
      def tmpdir
        helli_tmpdir = "#{Dir.tmpdir}/helli"
        FileUtils.mkdir_p(helli_tmpdir)
        Dir.mktmpdir(nil, helli_tmpdir)
      end
    end
  end
end
