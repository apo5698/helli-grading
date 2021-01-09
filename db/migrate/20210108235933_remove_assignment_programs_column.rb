class RemoveAssignmentProgramsColumn < ActiveRecord::Migration[6.1]
  def change
    remove_column :assignments, :programs, :array
  end
end
