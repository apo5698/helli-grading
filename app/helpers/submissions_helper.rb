require 'zip'

module SubmissionsHelper
  # Creates a submission if it does not exist and returns an Submission object.
  def self.create(student_id, assignment_id)
    s = Submission.find_by(student_id: student_id, assignment_id: assignment_id)
    s || Submission.create(student_id: student_id, assignment_id: assignment_id)
  end

  # Renames Moodle submission identifier to 'last_name first_name'
  def self.rename_moodle_id(dirname)
    dirname.split('__')[0]
  end
end
