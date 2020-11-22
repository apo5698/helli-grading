class CreateRubrics < ActiveRecord::Migration[6.0]
  def change
    create_table :rubrics do |t|
      t.belongs_to :assignment
      t.string :type, null: false
      t.string :primary_file
      t.string :secondary_file
      t.decimal :maximum_grade, precision: 5, scale: 2, default: 0, null: false
      t.timestamps
    end
  end
end
