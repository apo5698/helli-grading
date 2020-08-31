class CreateAssignments < ActiveRecord::Migration[6.0]
  def change
    create_table :assignments do |t|
      t.integer :type
      t.references :course
      t.timestamps
    end
  end
end
