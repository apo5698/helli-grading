module FileHelper
  # Creates/uploads a file to destination folder
  # or a directory and all its parent directories.
  # Keyword arguments are required. For example:
  #   FileHelper.create *file*: files, *dest*: dest
  #   FileHelper.create *dir*: dest
  def self.create(file: nil, dest: nil, dir: nil)
    if file && dest && dir.nil?
      ApplicationHelper.log_action action: 'create', from: file.original_filename, to: dest
      File.open(File.join(dest, file.original_filename), 'wb') do |f|
        content = file.read
        raise EmptyFileError if content.nil?

        f.write content
      end
    elsif dir && file.nil? && dest.nil?
      ApplicationHelper.log_action action: 'create', from: dir
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
    else
      raise NoFileSelectedError
    end
  end

  # Renames the given file/directory to the new name.
  def self.rename(old, new)
    ApplicationHelper.log_action action: 'rename', from: old, to: new
    File.rename old, new
  end

  # Removes a file system entry +path+.
  # +path+ shall be a regular file, a directory, or something.
  # If +path+ is a directory, remove it recursively.
  def self.remove(path)
    ApplicationHelper.log_action action: 'delete', from: path
    FileUtils.remove_entry_secure path
  end

  # +Error+ class contains several runtime errors related to file.
  class Error
    # Raised when a file to be created is empty (contains zero byte).
    class EmptyFileError < StandardError
      def initialize(msg = 'File is empty.')
        super msg
      end
    end

    # Raised when a file cannot be found during creating.
    class FileNotFoundError < StandardError
      def initialize(msg = 'File not found.')
        super msg
      end
    end

    # Raised when given files list is empty.
    class NoFileSelectedError < StandardError
      def initialize(msg = 'No file selected.')
        super msg
      end
    end
  end
end
