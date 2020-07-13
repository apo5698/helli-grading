class CreateTsFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :ts_files do |t|
      t.references :assignments
      t.string :filename
      t.timestamps
    end
  end
end
