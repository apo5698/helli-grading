class CreateGrades < ActiveRecord::Migration[6.0]
  def change
    create_table :grades do |t|
      t.belongs_to :participant, index: { unique: true }
      t.integer :identifier, null: false
      t.string :full_name, null: false
      t.string :email_address, null: false
      t.string :status, null: false
      t.decimal :grade, precision: 5, scale: 2
      t.decimal :maximum_grade, precision: 5, scale: 2, null: false
      t.boolean :grade_can_be_changed, null: false
      t.datetime :last_modified_submission
      t.datetime :last_modified_grade
      t.text :feedback_comments
      t.timestamps
    end
  end
end
