class CreateAssignments < ActiveRecord::Migration[6.0]
  def change
    create_table :assignments do |t|
      t.string :name
      t.string :type
      t.string :term
      t.string :course
      t.string :section
      t.text :description
      t.timestamps
    end
  end
end
