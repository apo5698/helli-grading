module CriterionsHelper
  def validate_points(status, messages)
    if points.blank?
      status = :incomplete
      messages << 'Points must be provided'
    elsif points.negative?
      status = :incomplete
      messages << 'Points must be a non-negative number'
    end
    [status, messages]
  end

  def validate_criterion(status, messages)
    if criterion.blank?
      status = :incomplete
      messages << 'Criterion cannot be blank'
    end
    [status, messages]
  end
end
