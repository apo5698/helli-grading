module StudentsHelper
  # Creates a student if it does not exist and returns an Student object.
  def self.create(first_name, last_name, email, course_id)
    s = Student.find_by(first_name: first_name, last_name: last_name, email: email, course_id: course_id)
    s || Student.create(first_name: first_name, last_name: last_name, email: email, course_id: course_id)
  end
end
