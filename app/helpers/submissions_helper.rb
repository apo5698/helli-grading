require 'zip'

module SubmissionsHelper
  # Creates a submission if it does not exist and returns an Submission object.
  def self.create(student_id, assignment_id)
    s = Submission.find_by(student_id: student_id, assignment_id: assignment_id)
    s || Submission.create(student_id: student_id, assignment_id: assignment_id)
  end

  # Renames Moodle submission identifier to 'first_name last_name'
  def self.rename_moodle_id(dirname)
    name = dirname.split('__')[0].split(' ')
    name[0], name[1] = name[1], name[0]
    name.join(' ')
  end
end
