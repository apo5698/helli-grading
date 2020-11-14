ActiveStorage::Attached::Many.class_eval do
  def find_by_filename(name)
    attachments.find { |f| f.filename == name }
  end

  def delete_by_filename(name)
    find_by_filename(name).purge
  end
end
