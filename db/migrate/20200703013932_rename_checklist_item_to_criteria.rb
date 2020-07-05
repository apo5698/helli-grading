class RenameChecklistItemToCriteria < ActiveRecord::Migration[6.0]
  def change
    rename_table :checklist_items, :criteria
  end
end
