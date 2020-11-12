class CreateTsFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :ts_files do |t|
      t.belongs_to :assignment
      t.timestamps
    end
  end
end
