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
      return if Dir.exist?(dir)

      ApplicationHelper.log_action action: 'create', from: dir
      FileUtils.mkdir_p(dir)
    else
      raise NoFileSelectedError
    end
  end

  # Returns an array of filenames under +path+
  # +path+ shall be a regular file, a directory, or something.
  # If +path+ is a directory, remove it recursively.
  def self.dir_names(path)
    Dir.glob(path.join('**')).select { |f| File.directory?(f) }.map { |f| File.basename(f) }.sort
  end

  # Returns the information of file in an array:
  #   - Filename
  #   - Size
  #   - Last modified
  def self.info(path)
    file_name = File.basename(path)
    file_size = ActiveSupport::NumberHelper.number_to_human_size(File.size(File.join(path)))
    file_mtime = File.mtime(File.join(path)).strftime('%x %X')
    [file_name, file_size, file_mtime]
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

  # Returns a hash which keys contain directory name and values contain contents.
  # For example:
  #   {"/"=>["exercise1.zip",
  #          "grade.csv",
  #          {"submissions"=>[{"student1"=>["Hello.java",
  #                                         "World.java"],
  #                            "student2"=>["Test.java"]}]}
  #         ]
  #   }
  def self.tree(dir, depth:)
    tree = {}

    case depth
    when 1
      tree['/'] = Dir[File.join(dir, '**')].sort
    when 2
      d1 = Dir[File.join(dir, '**')].sort
      tree['/'] = d1.select { |e| File.file?(e) }.map { |e| e.sub(dir.to_s, '') }
      d1.select { |e| File.directory?(e) }.each do |f|
        tree['/' + File.basename(f)] = Dir[File.join(f, '**')].map { |e| e.sub(dir.to_s, '') }
      end
    when 3
      d1 = Dir[File.join(dir, '**')].sort
      tree['/'] = d1.select { |e| File.file?(e) }.map { |e| e.sub(dir.to_s, '') }
      d1.select { |e| File.directory?(e) }.each do |f|
        d2 = Dir[File.join(f, '**')].sort
        tree['/' + File.basename(f)] = d2.select { |e| File.file?(e) }.map { |e| e.sub(dir.to_s, '') }
        d2.select { |e| File.directory?(e) }.each do |g|
          tree['/' + File.basename(f)] << { "/#{File.basename(f)}/#{File.basename(g)}" =>
                                              Dir[File.join(g, '**')].map { |e| e.sub(dir.to_s, '') }.sort }
        end
      end
    else
      raise ArgumentError, 'Allowed depth range: 1-3' if depth < 1 || depth > 3
    end
    # puts tree.to_json
    tree
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
