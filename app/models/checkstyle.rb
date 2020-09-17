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
    options = options[:checkstyle].transform_values(&:to_i)
    raise StandardError, 'No checkstyle rule selected.' if options.values.all? { |v| v.zero? }

    # checkstyle errors are in stdout, not stderr
    stdout = ProcessUtil.checkstyle(path)[:stdout]
    output = "[#{File.basename(path)}] - Checkstyle\n"\
             "[stdout]\n#{stdout}".strip
    errors = output.split("\n").grep(/\[WARN\].+/)
    options.each { |name, check| errors = errors.grep_v(/#{name}/) if check.zero? } if errors.count > 0

    error_count = errors.count
    detail = "#{error_count} checkstyle error"
    if error_count.zero?
      status = GradingItem.session[:success]
    else
      status = GradingItem.session[:error]
      detail << 's' if error_count > 1
    end

    points = criterions.where(criterion_type: Criterion::AWARD).pluck(:points).sum
    points -= criterions.where(criterion_type: Criterion::DEDUCTION_EACH).pluck(:points).sum * error_count
    points = 0 if points < 0

    { status: status, detail: detail, output: errors.join("\n"), points: points, error_count: error_count }
  end
end
