class ChangeTypeToAssignmentType < ActiveRecord::Migration[6.0]
  def change
    rename_column :assignments, :type, :assignment_type
  end
end
