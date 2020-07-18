class AddStatusDetail < ActiveRecord::Migration[6.0]
  def change
    add_column :grading_items, :status_detail, :string
  end
end
