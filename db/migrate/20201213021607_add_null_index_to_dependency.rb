class AddNullIndexToDependency < ActiveRecord::Migration[6.0]
  def change
    change_column_null :dependencies, :name, false
    change_column_null :dependencies, :type, false
    change_column_null :dependencies, :version, false
    change_column_null :dependencies, :source, false
    change_column_null :dependencies, :path, false
    change_column_null :dependencies, :executable, false
    change_column_null :dependencies, :visibility, false
  end
end
