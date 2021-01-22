class CreateCourses < ActiveRecord::Migration[6.1]
  def change
    create_table :courses do |t|
      t.belongs_to :user
      t.bigint :collaborator_ids, default: [], array: true

      t.string :name, null: false
      t.string :section, null: false
      t.integer :term, null: false

      t.timestamps

      t.index %i[user_id name section term], unique: true
    end
  end
end
