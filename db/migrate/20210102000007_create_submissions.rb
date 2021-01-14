class CreateSubmissions < ActiveRecord::Migration[6.1]
  def change
    create_table :submissions do |t|
      t.belongs_to :participant

      t.timestamps
    end
  end
end
