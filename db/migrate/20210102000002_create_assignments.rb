class CreateAssignments < ActiveRecord::Migration[6.1]
  def change
    create_table :assignments do |t|
      t.belongs_to :course

      t.integer :identifier, index: { unique: true }
      t.string :name, null: false
      t.string :category, null: false
      t.text :description, null: false, default: ''

      t.references :scale

      t.timestamps

      t.index %i[course_id name], unique: true
    end
  end
end
