class CreateGradingItems < ActiveRecord::Migration[6.0]
  def change
    create_table :grading_items do |t|
      t.references :rubric_item, :submission
      t.integer :status
      t.decimal :points_received
      t.text :comments
      t.timestamps
    end
  end
end
