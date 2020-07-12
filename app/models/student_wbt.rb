class StudentWbt < RubricItem
  def title
    'Student WBT'
  end

  def usage
    'This step runs the student\'s white box tests against both the selected input file and the oracle file.'
  end

  def validate_files(status, messages)
    status, messages = super(status, messages)
    if secondary_file.blank?
      status = :incomplete
      messages << 'Oracle file must be provided'
    end
    [status, messages]
  end

  def fields
    super << 'oracle_file'
  end

  def self.model_name
    RubricItem.model_name
  end
end
