class AddUniquenessToStudents < ActiveRecord::Migration[6.0]
  def change
    add_index :students, [:first_name, :last_name, :course_id], unique: true
  end
end
