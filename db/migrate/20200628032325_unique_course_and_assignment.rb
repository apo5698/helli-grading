class UniqueCourseAndAssignment < ActiveRecord::Migration[6.0]
  def change
    add_index :courses, %i[name term section], unique: true
    add_index :assignments, %i[course_id name], unique: true
  end
end
