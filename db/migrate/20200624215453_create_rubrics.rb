class CreateRubrics < ActiveRecord::Migration[6.0]
  def change
    create_table :rubrics do |t|
      t.string :name
      t.integer :visibility
      t.references :user
      t.timestamps
    end
  end
end
