class CreatePrograms < ActiveRecord::Migration[6.1]
  def change
    create_table :programs do |t|
      t.belongs_to :assignment
      t.belongs_to :parent_program, references: :program

      t.string :name, null: false
      t.string :extension, null: false

      t.timestamps
    end
  end
end
