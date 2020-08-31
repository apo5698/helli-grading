class AddGradingItemStdout < ActiveRecord::Migration[6.0]
  def change
    add_column :grading_items, :output, :text, default: ''
  end
end
