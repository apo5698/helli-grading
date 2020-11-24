begin
  ActiveRecord::Base.connection
rescue ActiveRecord::NoDatabaseError
  return
else
  Rails.configuration.to_prepare do
    if Helli::Dependency.table_exists?
      Helli::Dependency.load(ENV['DEPENDENCIES_FILE'])
      Helli::Dependency.download_all
    end
  end
end
