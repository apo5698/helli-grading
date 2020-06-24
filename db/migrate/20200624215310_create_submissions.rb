class CreateSubmissions < ActiveRecord::Migration[6.0]
  def change
    create_table :submissions do |t|
      t.references :student, :assignment
      t.timestamps
    end
  end
end
