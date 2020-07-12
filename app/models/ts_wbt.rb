class TsWbt < RubricItem
  def title
    'TS WBT'
  end

  def usage
    'This step runs the teaching-staff\'s white box tests against the selected input file.'
  end

  def default_set
    [{criterion_type: 'Award / ea.', criterion: '# passed test[s]', response: '# failing test[s]'}]
  end

  def validate_files(status, messages)
    status, messages = super(status, messages)
    if secondary_file.blank?
      status = :incomplete
      messages << 'Test file must be provided'
    end
    [status, messages]
  end

  def fields
    super << 'test_file'
  end

  def self.model_name
    RubricItem.model_name
  end
end
