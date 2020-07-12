class Checkstyle < RubricItem
  def title
    'Checkstyle'
  end

  def usage
    'This step runs the checkstyle script'
  end

  def default_set
    [{criterion_type: 'Award', criterion: 'Maximum points'},
     {criterion_type: 'Deduction / ea.', criterion: '# checkstyle error[s]', response: '# checkstyle error[s]'}]
  end

  def self.model_name
    RubricItem.model_name
  end
end
