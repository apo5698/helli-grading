class ChangeGradingItemStatusTypeToString < ActiveRecord::Migration[6.0]
  def self.up
    change_table :grading_items do |t|
      t.change :status, :string
    end
  end

  def self.down
    change_table :grading_items do |t|
      t.change :status, :int
    end
  end
end
