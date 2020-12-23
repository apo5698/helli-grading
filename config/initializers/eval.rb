ActiveStorage::Attached::Many.class_eval do
  def find_by_filename(name)
    attachments.find { |f| f.filename == name }
  end

  def delete_by_filename(name)
    find_by_filename(name).purge
  end
end

NilClass.class_eval do
  def to_b
    false
  end
end

Object.class_eval do
  def instance_variables_inspect
    instance_variables.reduce({}) do |hash, var|
      hash.merge(Hash[var.to_s.delete_prefix('@').to_sym, instance_variable_get(var)])
    end
  end
end

String.class_eval do
  def to_b
    ActiveModel::Type::Boolean.new.cast(downcase)
  end
end

TrueClass.class_eval do
  def to_b
    self
  end
end

FalseClass.class_eval do
  def to_b
    self
  end
end
