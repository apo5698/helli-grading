class EditCriterionsAndRubricItemsTable < ActiveRecord::Migration[6.0]
  def change
    rename_column :criterions, :item_type, :criterion_type
    remove_column :rubric_items, :file_from_ts
    remove_column :rubric_items, :file_from_student
    rename_column :rubric_items, :type, :rubric_item_type
    remove_column :rubric_items, :points
    add_column :rubric_items, :primary_file, :string
    add_column :rubric_items, :secondary_file, :string
    add_column :rubric_items, :tertiary_file, :string
  end
end
