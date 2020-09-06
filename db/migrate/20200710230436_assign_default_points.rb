class AssignDefaultPoints < ActiveRecord::Migration[6.0]
  def change
    remove_column :grading_items, :points_received
    add_column :grading_items, :points_received, :decimal, default: 0
  end
end
