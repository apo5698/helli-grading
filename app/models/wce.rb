class Wce < RubricItem
  def title
    'Write/Compile/Execute'
  end

  def usage
    'This step compiles and executes the selected input file.'
  end

  def default_set
    [{criterion_type: 'Award', criterion: 'File is named \'[filename]\'', response: 'File is not named \'[filename]\''},
     {criterion_type: 'Award', criterion: 'Class is named \'[class_name]\'', response: 'Class is not named \'[class_name]\''},
     {criterion_type: 'Award', criterion: 'Program compiles', response: 'Program compiles'},
     {criterion_type: 'Award', criterion: 'Program executes', response: 'Program executes'}]
  end

  def self.model_name
    RubricItem.model_name
  end

  def grade(submission)
    'halli'
  end
end
