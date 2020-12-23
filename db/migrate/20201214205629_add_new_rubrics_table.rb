class AddNewRubricsTable < ActiveRecord::Migration[6.0]
  def change
    remove_reference :rubric_criteria, :rubric
    add_reference :rubric_criteria, :rubric_item
    add_reference :rubric_items, :rubric
    remove_reference :grade_items, :rubric
    add_reference :grade_items, :rubric_item

    create_table :rubrics do |t|
      t.belongs_to :assignment
      t.belongs_to :user
      t.boolean :published, default: FALSE
      t.timestamps
    end
  end
end
