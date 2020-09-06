class RenameCriteriaToCriterion < ActiveRecord::Migration[6.0]
  def change
    rename_table :criteria, :criterions
  end
end
