class CreateRubricCriteria < ActiveRecord::Migration[6.1]
  def change
    create_table :rubric_criteria do |t|
      t.belongs_to :rubric_item

      t.string :type, null: false
      t.string :action, null: false
      t.decimal :point, precision: 5, scale: 2, default: 0, null: false
      t.string :feedback, default: '', null: false

      t.timestamps
    end
  end
end
