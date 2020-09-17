class AddColumnsForFasterExport < ActiveRecord::Migration[6.0]
  def change
    add_column :students, :email, :string
    add_column :grading_items, :attachment_id, :bigint
    add_column :grading_items, :student_id, :bigint
  end
end
