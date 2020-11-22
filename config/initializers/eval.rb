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
