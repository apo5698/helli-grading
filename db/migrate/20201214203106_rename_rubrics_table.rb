class RenameRubricsTable < ActiveRecord::Migration[6.0]
  def change
    rename_table :rubrics, :rubric_items
    remove_reference :rubric_items, :assignment
  end
end
