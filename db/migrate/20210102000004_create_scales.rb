class CreateScales < ActiveRecord::Migration[6.1]
  def change
    create_table :scales do |t|
      t.string :type, null: false
      t.jsonb :scale, null: false, default: {}

      t.timestamps
    end
  end
end
