class RemovePathForDependency < ActiveRecord::Migration[6.0]
  def change
    remove_column :dependencies, :path, :string
  end
end
