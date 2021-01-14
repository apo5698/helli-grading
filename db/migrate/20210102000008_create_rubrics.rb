class CreateRubrics < ActiveRecord::Migration[6.1]
  def change
    create_table :rubrics do |t|
      t.belongs_to :user
      t.belongs_to :assignment

      t.boolean :published, null: false, default: false

      t.timestamps
    end
  end
end
