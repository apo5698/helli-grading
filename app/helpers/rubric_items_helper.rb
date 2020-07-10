module RubricItemsHelper
  ORACLE_FILE_TYPES = ['Student BBT', 'Student WBT'].freeze
  TEST_FILE_TYPES = ['TS WBT'].freeze
  BBTP_TYPES = ['Student BBT', 'TS BBT'].freeze
  DESCRIPTION_TYPES = ['Inspection', 'Student BBT', 'TS BBT'].freeze

  def default_set
    case rubric_item_type
    when 'Write/Compile/Execute'
      [{criterion_type: 'Award', criterion: 'File is named \'[filename]\'', response: 'File is not named \'[filename]\''},
       {criterion_type: 'Award', criterion: 'Class is named \'[class_name]\'', response: 'Class is not named \'[class_name]\''},
       {criterion_type: 'Award', criterion: 'Program compiles', response: 'Program compiles'},
       {criterion_type: 'Award', criterion: 'Program executes', response: 'Program executes'}]
    when 'Checkstyle'
      [{criterion_type: 'Award', criterion: 'Maximum points'},
       {criterion_type: 'Deduction / ea.', criterion: '# checkstyle error[s]', response: '# checkstyle error[s]'}]
    when 'Javadoc'
      [{criterion_type: 'Self-check', points: 1, criterion: 'Class constants are appropriately documented'},
       {criterion_type: 'Self-check', points: 1, criterion: 'Class comments fully describe the program’s functionality'},
       {criterion_type: 'Self-check', points: 1, criterion: 'Method comments fully describe behavior'},
       {criterion_type: 'Self-check', points: 1, criterion: 'Method comments fully describe parameter(s), return information, and exception(s) (if any)'},
       {criterion_type: 'Self-check', points: 0.5, criterion: 'Spelling'},
       {criterion_type: 'Self-check', points: 0.5, criterion: 'Grammar'}]
    when 'Student BBT'
      [{criterion_type: 'Award', criterion: 'Maximum points'},
       {criterion_type: 'Deduction / ea.', criterion: 'for each student test case with a repeatable criterion, specific and correct expected result, and a listed actual result that matches the student\'s output when running the test', response: '# checkstyle error[s]'}]
    when 'TS WBT'
      [{criterion_type: 'Award / ea.', criterion: '# passed test[s]', response: '# failing test[s]'}]
    else
      []
    end
  end

  def fields
    type = rubric_item_type
    fields = ['input_file']
    fields << 'oracle_file' if ORACLE_FILE_TYPES.include?(type)
    fields << 'bbtp' if BBTP_TYPES.include?(type)
    fields << 'test_file' if TEST_FILE_TYPES.include?(type)
    fields << 'description' if DESCRIPTION_TYPES.include?(type)
    fields
  end

  def default_description
    case rubric_item_type
    when 'Student BBT'
      'non-repeatable criterion and/or incorrect expected result and/or incorrect actual results'
    else
      ''
    end
  end

  def usage
    case rubric_item_type
    when 'Inspection'
      'This step renders the selected input file.'
    when 'Write/Compile/Execute'
      'This step compiles and executes the selected input file.'
    when 'Checkstyle'
      'This step runs the checkstyle script'
    when 'Javadoc'
      'This step checks for javadoc.'
    when 'Student BBT'
      'This step grants an interactive web console for grading the student\'s black box tests.'
    when 'Student WBT'
      'This step runs the student\'s white box tests against both the selected input file and the oracle file.'
    when 'TS BBT'
      'This step grants an interactive web console for grading the teaching-staff\'s black box tests.'
    when 'TS WBT'
      'This step runs the teaching-staff\'s white box tests against the selected input file.'
    else
      ''
    end
  end

  def validate_files(status = :completed, messages = [])
    status = :incomplete if primary_file.blank?
    status = :incomplete if secondary_file.blank? && (ORACLE_FILE_TYPES + TEST_FILE_TYPES).include?(rubric_item_type)
    status = :incomplete if tertiary_file.blank? && BBTP_TYPES.include?(rubric_item_type)
    messages << 'All files must be provided' if status == :incomplete
    [status, messages]
  end
end
