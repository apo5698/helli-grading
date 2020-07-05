class CreateRubricItems < ActiveRecord::Migration[6.0]
  def change
    create_table :rubric_items do |t|
      t.references :rubric
      t.integer :type
      t.integer :graded_by
      t.integer :seq
      t.decimal :points
      t.string :file_from_student
      t.string :file_from_ts
      t.text :criterion
      t.timestamps
    end
  end
end
