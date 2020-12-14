class AddCollaboratorsToCourse < ActiveRecord::Migration[6.0]
  def change
    change_table :courses, bulk: true do |t|
      t.bigint :collaborator_ids, default: [], array: true
    end
  end
end
