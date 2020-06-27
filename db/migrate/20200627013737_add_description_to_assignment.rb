class AddDescriptionToAssignment < ActiveRecord::Migration[6.0]
  def change
    add_column :assignments, :description, :text
  end
end
