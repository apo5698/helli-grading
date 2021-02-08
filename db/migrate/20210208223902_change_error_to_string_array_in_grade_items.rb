class ChangeErrorToStringArrayInGradeItems < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      change_table :grade_items, bulk: true do |t|
        dir.up do
          t.remove :error
          t.string :error, array: true, default: []
        end

        dir.down do
          t.remove :error
          t.integer :error, default: 0
        end
      end
    end
  end
end
