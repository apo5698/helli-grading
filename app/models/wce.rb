class Wce < RubricItem
  enum wce_criterion_type: [FILENAME_OK = "File is named '[filename]'",
                            CLASSNAME_OK = "Class is named '[classname]'",
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
    captures_javac = ProcessUtil.javac(file: path)
    filename = File.basename(path)
    output = "[#{filename}] - Compile\n"\
                  "[stdout]\n#{captures_javac[:stdout]}\n"\
                  "[stderr]\n#{captures_javac[:stderr]}\n"\
                  "[exit status] #{captures_javac[:status].exitstatus}\n\n"
    captures_java = ProcessUtil.java(file: path)
    output << "[#{filename}] - Run\n"\
                  "[stdout]\n#{captures_java[:stdout]}\n"\
                  "[stderr]\n#{captures_java[:stderr]}\n"\
                  "[exit status] #{captures_java[:status].exitstatus}"
    output.strip!

    can_compile = captures_java[:status].exitstatus.zero?
    can_run = captures_javac[:status].exitstatus.zero?

    points = 0
    points += criterions.find_by(criterion: FILENAME_OK).points if File.exist?(File.join(File.dirname(path), primary_file))
    points += criterions.find_by(criterion: CLASSNAME_OK).points unless output.include?('ClassNotFoundException')
    points += criterions.find_by(criterion: COMPILE_OK).points if can_compile
    points += criterions.find_by(criterion: RUN_OK).points if can_run

    success = can_compile && can_run
    if success
      status = GradingItem::SUCCESS
      detail = ''
    else
      status = GradingItem::ERROR
      detail = 'Error occurred while compiling/running.'
    end

    error_count = output.scan(/([eE]rror:)|(java.*Exception)/).length

    { status: status, detail: detail, output: output, points: points, error_count: error_count }
  end
end