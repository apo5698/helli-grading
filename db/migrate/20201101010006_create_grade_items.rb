class CreateGradeItems < ActiveRecord::Migration[6.0]
  def change
    create_table :grade_items do |t|
      t.belongs_to :participant
      t.belongs_to :rubric
      t.string :status, null: false
      t.text :stdout, default: '', null: false
      t.text :stderr, default: '', null: false
      t.integer :error, default: 0, null: false
      t.decimal :grade, precision: 5, scale: 2, default: 0, null: false
      t.text :feedback, default: '', null: false
      t.timestamps

      t.index %i[participant_id rubric_id], unique: true
    end
  end
end
