class CreateDependencies < ActiveRecord::Migration[6.0]
  def change
    create_table :dependencies do |t|
      t.string :name
      t.string :version
      t.string :source
      t.string :source_type
      t.string :executable
      t.string :path

      t.index :name, unique: true
      t.timestamps
    end
  end
end
