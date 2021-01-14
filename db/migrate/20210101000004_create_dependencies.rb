class CreateDependencies < ActiveRecord::Migration[6.1]
  def change
    create_table :dependencies do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :version
      t.string :source, null: false
      t.string :type, null: false
      t.string :executable, null: false
      t.string :checksum
      t.boolean :public, null: false, default: false

      t.timestamps
    end
  end
end
