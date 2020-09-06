class AddSubclassTypes < ActiveRecord::Migration[6.0]
  def change
    remove_column :rubric_items, :rubric_item_type
    add_column :rubric_items, :type, :string
  end
end
