class Wce < RubricItem
  enum wce_criterion_type: [FILENAME_OK = "File is named as expected",
                            CLASSNAME_OK = "Class is named as expected",
                            COMPILE_OK = 'Program compiles',
                            RUN_OK = 'Program runs']

  def title
    'Write/Compile/Execute'
  end

  def usage
    'This step compiles and executes the selected input file.'
  end

  def default_set
    [{ criterion_type: Criterion::AWARD, criterion: FILENAME_OK, response: FILENAME_OK },
     { criterion_type: Criterion::AWARD, criterion: CLASSNAME_OK, response: CLASSNAME_OK },
     { criterion_type: Criterion::AWARD, criterion: COMPILE_OK, response: COMPILE_OK },
     { criterion_type: Criterion::AWARD, criterion: RUN_OK, response: RUN_OK }]
  end

  def self.model_name
    RubricItem.model_name
  end

  def grade(path, options)
    options = options[:wce]
    junit = options[:lib][:junit].to_i == 1

    captures_javac = Command::Java.javac(path, junit: junit, args: options[:args][:javac])
    filename = File.basename(path)
    output = "[#{filename}] - Compile\n"\
                  "[stdout]\n#{captures_javac[:stdout]}\n"\
                  "[stderr]\n#{captures_javac[:stderr]}\n"\
                  "[exit status] #{captures_javac[:exitcode]}\n\n"

    begin
      captures_java = Command::Java.java(path,
                                         junit: junit,
                                         args: options[:args][:java],
                                         stdin: options[:stdin][:data])
    rescue Command::Java::CompileError => e
      captures_java = { stdout: '', stderr: e.message, exitcode: -1 }
    end

    output << "[#{filename}] - Run\n"\
                  "[stdout]\n#{captures_java[:stdout]}\n"\
                  "[stderr]\n#{captures_java[:stderr]}\n"\
                  "[exit status] #{captures_java[:exitcode]}"
    output.strip!

    can_compile = captures_javac[:exitcode].zero?
    can_run = captures_java[:exitcode].zero?

    points = 0
    points += criterions.find_by(criterion: FILENAME_OK).points if File.exist?(File.join(File.dirname(path), primary_file))
    points += criterions.find_by(criterion: CLASSNAME_OK).points unless output.include?('ClassNotFoundException')
    points += criterions.find_by(criterion: COMPILE_OK).points if can_compile
    points += criterions.find_by(criterion: RUN_OK).points if can_run

    error_count = output.scan(/([eE]rror:)|(java.*Exception)/).length
    status = can_compile && can_run ? GradingItem.statuses[:success] : GradingItem.statuses[:error]
    detail = "#{error_count} error"
    detail << 's' if error_count > 1

    detail << ", javac exited with code #{captures_javac[:exitcode]}" unless can_compile
    detail << ", java exited with code #{captures_java[:exitcode]}" unless can_run

    { status: status, detail: detail, output: output, points: points, error_count: error_count }
  end
end