class AddChecksumForDependency < ActiveRecord::Migration[6.0]
  def change
    add_column :dependencies, :checksum, :string
  end
end
