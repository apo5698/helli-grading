class AddUuidToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :uuid, :string
  end
end
