class ChangeVisibilityToBooleanValue < ActiveRecord::Migration[6.0]
  def change
    remove_column :rubrics, :visibility
    add_column :rubrics, :visibility, :boolean
  end
end
