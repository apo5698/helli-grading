class FixRefactorError < ActiveRecord::Migration[6.0]
  def change
    rename_column :assignments, :criterion, :description
    rename_column :rubric_items, :criterion, :description
  end
end
