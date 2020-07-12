class StudentBbt < RubricItem
  def title
    'Student BBT'
  end

  def usage
    'This step grants an interactive web console for grading the student\'s black box tests.'
  end

  def default_set
    [{criterion_type: 'Award', criterion: 'Maximum points'},
     {criterion_type: 'Deduction / ea.', criterion: 'for each student test case with a repeatable criterion, specific ' \
'and correct expected result, and a listed actual result that matches the student\'s output when running the test',
      response: '# checkstyle error[s]'}]
  end

  def default_description
    'non-repeatable criterion and/or incorrect expected result and/or incorrect actual results'
  end

  def validate_files(status, messages)
    status, messages = super(status, messages)
    if secondary_file.blank?
      status = :incomplete
      messages << 'Oracle file must be provided'
    end
    if tertiary_file.blank?
      status = :incomplete
      messages << 'BBTP must be provided'
    end
    [status, messages]
  end

  def fields
    super << 'oracle_file' << 'bbtp'
  end

  def self.model_name
    RubricItem.model_name
  end
end
