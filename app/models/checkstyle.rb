class Checkstyle < RubricItem
  def title
    'Checkstyle'
  end

  def usage
    'This step runs the checkstyle script'
  end

  def default_set
    [{ criterion_type: 'Award', criterion: 'Maximum points' },
     { criterion_type: 'Deduction / ea.', criterion: '# checkstyle error[s]', response: '# checkstyle error[s]' }]
  end

  def self.model_name
    RubricItem.model_name
  end

  def grade(file, options)
    captures = ProcessUtil.checkstyle(file)
    filename = file.filename
    output = "[#{filename}] - Checkstyle\n"\
             "[stdout]\n" << captures[:stdout]
    output.strip!

    options = options[:checkstyle].transform_values(&:to_i)
    errors = output.split("\n").grep(/#{filename.to_s}:.+/)
    if errors.count > 0
      errors = errors.grep_v(/magic number/) if options[:magic].zero?
      errors = errors.grep_v(/Javadoc/) if options[:javadoc].zero?
      errors = errors.grep_v(/indentation/) if options[:indentation].zero?
      errors = errors.grep_v(/longer/) if options[:length].zero?
      errors = errors.grep_v(/pattern/) if options[:pattern].zero?
      errors = errors.grep_v(/tab/) if options[:tab].zero?
      errors = errors.grep_v(/whitespace/) if options[:whitespace].zero?
    end

    count = errors.count
    _detail = "#{count} checkstyle error"
    if count.zero?
      _status = GradingItem::SUCCESS
    else
      _status = GradingItem::ERROR
      _detail << 's' if count > 1
    end

    _points = criterions.where(criterion_type: Criterion::AWARD).pluck(:points).sum
    _points -= criterions.where(criterion_type: Criterion::DEDUCTION_EACH).pluck(:points).sum * count
    _points = 0 if _points < 0

    { status: _status, detail: _detail, output: errors.join("\n"), points: _points }
  end
end
