class CreateParticipants < ActiveRecord::Migration[6.1]
  def change
    create_table :participants do |t|
      t.belongs_to :assignment
      t.belongs_to :student

      t.integer :identifier, null: false
      t.string :full_name, null: false
      t.string :email_address, null: false
      t.boolean :status, null: false
      t.decimal :grade, precision: 5, scale: 2
      t.decimal :maximum_grade, precision: 5, scale: 2, null: false
      t.boolean :grade_can_be_changed, default: true, null: false
      t.datetime :last_modified_submission
      t.datetime :last_modified_grade
      t.text :feedback_comments

      t.timestamps

      t.index %i[assignment_id student_id], unique: true
    end
  end
end
