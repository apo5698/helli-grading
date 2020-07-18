module AssignmentsHelper
  # Returns +true+ if an assignment has submission.
  def self.has_submission?(assignment_id)
    !Submission.where(assignment_id: assignment_id).blank?
  end
end
