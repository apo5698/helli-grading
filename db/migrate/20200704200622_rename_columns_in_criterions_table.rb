class RenameColumnsInCriterionsTable < ActiveRecord::Migration[6.0]
  def change
    rename_column :criterions, :item_type, :item_type
    rename_column :criterions, :criterion, :criterion
  end
end
