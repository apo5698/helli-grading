class CreateChecklistItems < ActiveRecord::Migration[6.0]
  def change
    create_table :checklist_items do |t|
      t.references :rubric_item
      t.decimal :points
      t.boolean :checked
      t.text :description
      t.timestamps
    end
  end
end
