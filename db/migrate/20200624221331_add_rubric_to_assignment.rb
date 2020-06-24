class AddRubricToAssignment < ActiveRecord::Migration[6.0]
  def change
    add_reference :assignments, :rubric
  end
end
