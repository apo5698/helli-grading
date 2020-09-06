class ChangeCriterionsTable < ActiveRecord::Migration[6.0]
  def change
    remove_column :criterions, :checked
    remove_column :criterions, :criterion
    add_column :criterions, :item_type, :integer
    add_column :criterions, :criterion, :string
    add_column :criterions, :response, :string
  end
end
