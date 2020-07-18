class Wce < RubricItem
  def title
    'Write/Compile/Execute'
  end

  def usage
    'This step compiles and executes the selected input file.'
  end

  def default_set
    [{ criterion_type: 'Award', criterion: 'File is named \'[filename]\'', response: 'File is not named \'[filename]\'' },
     { criterion_type: 'Award', criterion: 'Class is named \'[class_name]\'', response: 'Class is not named \'[class_name]\'' },
     { criterion_type: 'Award', criterion: 'Program compiles', response: 'Program compiles' },
     { criterion_type: 'Award', criterion: 'Program executes', response: 'Program executes' }]
  end

  def self.model_name
    RubricItem.model_name
  end

  def grade(submission_files)
    if submission_files.length.zero?
      { 'Error occurred': "No submission.\n(0 file submitted)" }
    elsif !submission_files.map { |e| e.filename }.include?(primary_file)
      { 'Error occurred': "No submission.\n(File '#{primary_file}' not found)" }
    else
      result = ''
      tmpdir = Dir.tmpdir
      submission_files.select { |f| f.filename.to_s.end_with?('.java') }.each do |f|
        path = File.join(tmpdir, f.id.to_s, f.filename.to_s)
        FileUtils.mkdir_p(File.dirname(path))
        File.open(path, 'wb') { |g| g.write(f.download) }

        exec_output = JavaHelper.javac(file: path)
        result << "[#{f.filename.to_s}]\n#{exec_output[:stderr]}\n" unless exec_output[:status].exitstatus.zero?

        FileUtils.remove_entry_secure(File.dirname(path))
      end

      result.empty? ? { 'Graded': 'No issue found' } : { 'Error occurred': result }
    end
  end
end