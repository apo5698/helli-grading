class Javadoc < RubricItem
  def title
    'Javadoc'
  end

  def usage
    'This step checks for javadoc.'
  end

  def default_set
    [{ criterion_type: 'Self-check', points: 1, criterion: 'Class constants are appropriately documented' },
     { criterion_type: 'Self-check', points: 1, criterion: 'Class comments fully describe the program’s functionality' },
     { criterion_type: 'Self-check', points: 1, criterion: 'Method comments fully describe behavior' },
     { criterion_type: 'Self-check', points: 1, criterion: 'Method comments fully describe parameter(s), return information, and exception(s) (if any)' },
     { criterion_type: 'Self-check', points: 0.5, criterion: 'Spelling' },
     { criterion_type: 'Self-check', points: 0.5, criterion: 'Grammar' }]
  end

  def self.model_name
    RubricItem.model_name
  end

  def grade(submission_files)
    raise StandardError, 'Not yet implemented'
  end
end
