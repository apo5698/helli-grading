class SetCriterionDefaultPointToZero < ActiveRecord::Migration[6.0]
  def change
    change_column :criterions, :points, :decimal, default: 0, precision: 5, scale: 2
  end
end
