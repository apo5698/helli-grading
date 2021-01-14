class CreateRubricItems < ActiveRecord::Migration[6.1]
  def change
    create_table :rubric_items do |t|
      t.belongs_to :rubric

      t.string :type, null: false
      t.string :filename

      t.timestamps
    end
  end
end
