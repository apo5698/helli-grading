class CreateParticipants < ActiveRecord::Migration[6.0]
  def change
    create_table :participants do |t|
      t.belongs_to :assignment
      t.belongs_to :student
      t.decimal :program_total, precision: 5, scale: 2, default: 0, null: false
      t.decimal :zybooks_total, precision: 5, scale: 2
      t.decimal :other_total, precision: 5, scale: 2
      t.timestamps

      t.index %i[assignment_id student_id], unique: true
    end
  end
end
