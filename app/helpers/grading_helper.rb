module GradingHelper
  def self.checkstyle(files) end

  # Compiles given files to specified directory.
  # File(s) can be path to a single file or paths to multiple files in an Array.
  # +to+ is the relative path to the dirname of file can be a Pathname or String.
  # +options+ and +args+ must be hashes.
  # For example:
  #   files = ["/student1/src/HelloWorld.java", "/student2/src/Something.java"]
  #   GradingHelper.compile files, to: '../bin', options: {"junit"=>"1"}, args: {"-t"}
  # will execute:
  #   javac -d "/student1/src/../bin" -cp "/student1/bin:@lib_path/*" "/student1/src/HelloWorld.java" "-t"
  #   javac -d "/student2/src/../bin" -cp "/student2/bin:@lib_path/*" "/student2/src/Something.java" "-t"
  # where +@lib_path+ is AGS public java libraries directory (depend on server configuration).
  def self.compile(files, to:, lib: nil, options: nil, args: nil)
    raise FileHelper::Error::NoFileSelectedError if files.empty?

    console_out = { stdout: '', stderr: '' }
    files.each do |file|
      dirname = File.dirname(file)
      d_path = to == '.' ? dirname : File.join(dirname, to)
      cp_path = lib && options && options[:junit].to_i == 1 ? "#{d_path}:#{lib}/*" : d_path
      ret = GradingHelper.exec('javac',
                               '-d', "\"#{d_path}\"",
                               '-cp', "\"#{cp_path}\"",
                               "\"#{file}\"", args || '',
                               dirname: dirname)
      console_out[:stdout] << (ret[:stdout] + "\n\n") unless ret[:stdout].empty?
      console_out[:stderr] << (ret[:stderr] + "\n\n") unless ret[:stderr].empty?
    end

    console_out
  end

  # Compiles a file or files to its current directory without any parameter.
  # For example:
  #   files = ["/student1/HelloWorld.java", "/student2/Something.java"]
  #   GradingHelper.compile_simple files
  # will execute:
  #   javac -d "/student1" "/student1/HelloWorld.java"
  #   javac -d "/student2" "/student2/Something.java"
  def self.compile_simple(files)
    compile files, to: '.'
  end

  def self.delete(files)
    UploadHelper.delete(files)
  end

  def self.delete!(files)
    UploadHelper.delete!(files)
  end

  def self.run(files) end

  # Return +true+ if a Java source file is compiled (+*.class+ exists).
  def self.is_compiled?(java_file)
    # If an assignment is using flat structure,
    # '/src/' will not present in path, so +sub+ does nothing here,
    # Therefore, +*.class+ will be in the same directory as source file.
    File.exist? java_file.sub('/src/', '/bin/').sub(/.java\z/, '.class')
  end

  def self.source_exists?(java_class) end

  def self.unzip(zip, dest)
    UploadHelper.unzip(zip, dest, from_moodle: true)
  end

  def self.upload(files, dest)
    UploadHelper.upload(files, dest)
  end

  def self.exec(*cmd, dirname: nil)
    puts 'GradingHelper::exec'.magenta.bold
    puts cmd.join("\n")

    output = { stdout: nil, stderr: nil }
    Open3.popen3(cmd.join(' ')) do |_, stdout, stderr, _|
      output[:stdout] = stdout.read.gsub(dirname || '', '').strip
      output[:stderr] = stderr.read.gsub(dirname || '', '').strip
    end

    puts "  #{'stdout:'.yellow.bold} #{output[:stdout].gsub("\n", "\n#{' ' * 10}")}"
    puts "  #{'stderr:'.yellow.bold} #{output[:stderr].gsub("\n", "\n#{' ' * 10}")}"
    output
  end
end
