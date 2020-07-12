class TsBbt < RubricItem
  def title
    'TS BBT'
  end

  def usage
    'This step grants an interactive web console for grading the teaching-staff\'s black box tests.'
  end

  def validate_files(status, messages)
    status, messages = super(status, messages)
    if tertiary_file.blank?
      status = :incomplete
      messages << 'BBTP must be provided'
    end
    [status, messages]
  end

  def fields
    super << 'bbtp'
  end

  def self.model_name
    RubricItem.model_name
  end
end
