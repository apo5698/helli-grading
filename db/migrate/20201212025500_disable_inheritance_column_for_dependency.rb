class DisableInheritanceColumnForDependency < ActiveRecord::Migration[6.0]
  def change
    rename_column :dependencies, :source_type, :type
  end
end
