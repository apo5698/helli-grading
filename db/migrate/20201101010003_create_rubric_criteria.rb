class CreateRubricCriteria < ActiveRecord::Migration[6.0]
  def change
    create_table :rubric_criteria do |t|
      t.belongs_to :rubric
      t.string :action, null: false
      t.decimal :point, precision: 5, scale: 2, default: 0, null: false
      t.string :criterion, null: false
      t.text :feedback, default: '', null: false
      t.timestamps
    end
  end
end
