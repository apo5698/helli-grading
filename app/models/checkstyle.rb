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

  def grade(path, options)
    captures = ProcessUtil.checkstyle(path)
    filename = File.basename(path)
    output = "[#{filename}] - Checkstyle\n"\
             "[stdout]\n" << captures[:stdout]
    output.strip!


    options = options[:checkstyle].transform_values(&:to_i)
    errors = output.split("\n").grep(/#{filename}:.+/)
    if errors.count > 0
      errors = errors.grep_v(/magic number/) if options[:magic].zero?
      errors = errors.grep_v(/Javadoc/) if options[:javadoc].zero?
      errors = errors.grep_v(/indentation/) if options[:indentation].zero?
      errors = errors.grep_v(/longer/) if options[:length].zero?
      errors = errors.grep_v(/pattern/) if options[:pattern].zero?
      errors = errors.grep_v(/tab/) if options[:tab].zero?
      errors = errors.grep_v(/whitespace/) if options[:whitespace].zero?
    end

    error_count = errors.count
    detail = "#{error_count} checkstyle error"
    if error_count.zero?
      status = GradingItem::SUCCESS
    else
      status = GradingItem::ERROR
      detail << 's' if error_count > 1
    end

    points = criterions.where(criterion_type: Criterion::AWARD).pluck(:points).sum
    points -= criterions.where(criterion_type: Criterion::DEDUCTION_EACH).pluck(:points).sum * error_count
    points = 0 if points < 0

    { status: status, detail: detail, output: output, points: points, error_count: error_count }
  end
end
