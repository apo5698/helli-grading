class CreateAssignments < ActiveRecord::Migration[6.0]
  def change
    create_table :assignments do |t|
      t.belongs_to :course
      t.string :name, null: false
      t.string :category, null: false
      t.text :description, default: '', null: false
      t.string :programs, default: [], null: false, array: true
      t.jsonb :grades_scale, default: {}, null: false
      t.jsonb :zybooks_scale, default: {}, null: false
      t.timestamps

      t.index %i[course_id name], unique: true
      t.index %i[grades_scale zybooks_scale], using: :gin
    end
  end
end
