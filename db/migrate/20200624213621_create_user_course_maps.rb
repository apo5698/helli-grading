class CreateUserCourseMaps < ActiveRecord::Migration[6.0]
  def change
    create_table :user_course_maps do |t|
      t.references :user, :course
      t.timestamps
    end
  end
end
