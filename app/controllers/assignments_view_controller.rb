# Controller for all views of single assignment
class AssignmentsViewController < ApplicationController
  before_action lambda {
    @course = Course.find(params.require(:course_id))

    id = params[:assignment_id] || params[:id]
    @assignment = Assignment.find(id) if id

    if @assignment
      # records
      @participants = @assignment.participants.order(:created_at)
      @submissions = @assignment.submissions
      @rubrics = @assignment.rubrics
      @grades = @assignment.grades.order(:created_at)

      # statuses
      @has_program = @assignment.programs.present?
      @has_input_files = @assignment.input_files.attached?
      @has_grades_uploaded = @grades.any?
      @has_submission = @submissions.present?
      @has_rubric = @rubrics.all? { |r| r.rubric_criteria.any? }
      @has_grades_filled = @grades.pluck(:grade).any?
    end
  }

  # #  GET /
  # def index; end
  #
  # #  GET /new
  # def new; end
  #
  # #  POST /
  # def create; end
  #
  # #  GET /:id
  # def show; end
  #
  # #  GET /:id/edit
  # def edit; end
  #
  # #  PUT /:id
  # def update; end
  #
  # #  DELETE /:id
  # def destroy; end
end
