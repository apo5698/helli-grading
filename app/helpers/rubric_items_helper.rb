module RubricItemsHelper
  def default_set_for_wce
    [{criterion_type: 'Award', criterion: 'File is named \'[filename]\'', response: 'File is not named \'[filename]\''},
     {criterion_type: 'Award', criterion: 'Class is named \'[class_name]\'', response: 'Class is not named \'[class_name]\''},
     {criterion_type: 'Award', criterion: 'Program compiles', response: 'Program compiles'},
     {criterion_type: 'Award', criterion: 'Program executes', response: 'Program executes'}]
  end

  def default_set_for_checkstyle
    [{criterion_type: 'Award', criterion: 'Maximum points'},
     {criterion_type: 'Deduction / ea.', criterion: '# checkstyle error[s]', response: '# checkstyle error[s]'}]
  end

  def default_set_for_javadoc
    [{criterion_type: 'Self-check', points: 1, criterion: 'Class constants are appropriately documented'},
     {criterion_type: 'Self-check', points: 1, criterion: 'Class comments fully describe the program’s functionality'},
     {criterion_type: 'Self-check', points: 1, criterion: 'Method comments fully describe behavior'},
     {criterion_type: 'Self-check', points: 1, criterion: 'Method comments fully describe parameter(s), return information, and exception(s) (if any)'},
     {criterion_type: 'Self-check', points: 0.5, criterion: 'Spelling'},
     {criterion_type: 'Self-check', points: 0.5, criterion: 'Grammar'}]
  end

  def default_set_for_student_bbt
    [{criterion_type: 'Award', criterion: 'Maximum points'},
     {criterion_type: 'Deduction / ea.', criterion: 'for each student test case with a repeatable criterion, specific and correct expected result, and a listed actual result that matches the student\'s output when running the test', response: '# checkstyle error[s]'}]
  end

  def default_description_for_student_bbt
    'non-repeatable criterion and/or incorrect expected result and/or incorrect actual results'
  end

  def default_set_for_ts_wbt
    [{criterion_type: 'Award / ea.', criterion: '# passed test[s]', response: '# failing test[s]'}]
  end
end
