class AddFileInfoToGradingItem < ActiveRecord::Migration[6.0]
  def change
    add_column :grading_items, :filename, :string
    add_column :grading_items, :file_content, :text
  end
end
