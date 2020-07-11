class AddPrecision < ActiveRecord::Migration[6.0]
  def change
    remove_column :criterions, :points
    remove_column :grading_items, :points_received
    add_column :criterions, :points, :decimal, default: 0, precision: 8, scale: 2
    add_column :grading_items, :points_received, :decimal, default: 0, precision: 8, scale: 2
  end
end
