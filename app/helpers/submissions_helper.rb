module SubmissionsHelper
  # Creates a submission if it does not exist and returns an Submission object.
  def self.create(student_id, assignment_id)
    s = Submission.find_by(student_id: student_id, assignment_id: assignment_id)
    s || Submission.create(student_id: student_id, assignment_id: assignment_id)
  end
end
