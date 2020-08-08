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

  def grade(file, options)
    captures_javac = ProcessUtil.javac(file: file)
    filename = File.basename(file)
    output = "[#{filename}] - Compile\n"\
                  "[stdout]\n#{captures_javac[:stdout]}"\
                  "[stderr]\n#{captures_javac[:stderr]}"\
                  "[exit status] #{captures_javac[:status].exitstatus}\n\n"
    captures_java = ProcessUtil.java(file: file)
    output << "[#{filename}] - Run\n"\
                  "[stdout]\n#{captures_java[:stdout]}"\
                  "[stderr]\n#{captures_java[:stderr]}"\
                  "[exit status] #{captures_java[:status].exitstatus}"
    output.strip!

    can_compile = captures_java[:status].exitstatus.zero?
    can_run = captures_javac[:status].exitstatus.zero?

    _points = 0
    _points += criterions.find_by(criterion: FILENAME_OK).points if File.exist?(File.join(File.dirname(file), primary_file))
    _points += criterions.find_by(criterion: CLASSNAME_OK).points unless output.include?('ClassNotFoundException')
    _points += criterions.find_by(criterion: COMPILE_OK).points if can_compile
    _points += criterions.find_by(criterion: RUN_OK).points if can_run

    success = can_compile && can_run
    if success
      _status = GradingItem::SUCCESS
      _detail = ''
    else
      _status = GradingItem::ERROR
      _detail = 'Error occurred while compiling/running.'
    end

    { status: _status, detail: _detail, output: output, points: _points }
  end
end