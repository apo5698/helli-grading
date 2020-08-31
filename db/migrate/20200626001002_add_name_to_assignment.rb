class AddNameToAssignment < ActiveRecord::Migration[6.0]
  def change
    add_column :assignments, :name, :string
  end
end
