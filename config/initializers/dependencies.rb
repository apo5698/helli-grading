# skip loading when running database related tasks (such as rake db:migrate)
if ActiveRecord::Base.connection.table_exists?('dependencies') &&
   !ActiveRecord::Base.connection.migration_context.needs_migration?
  Dependency.load('config/dependencies.yml')
  Dependency.download
end
