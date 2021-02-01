# frozen_string_literal: true

# Controller for all views of single assignment
class AssignmentsViewController < ApplicationController
  before_action lambda {
    @course = Course.find(params.require(:course_id))
  }

  before_action lambda {
    assignment_id = params[:assignment_id] || params[:id]
    return unless assignment_id

    @assignment = Assignment.find(assignment_id)

    # records
    @programs = @assignment.programs
    @participants = @assignment.participants.order(:created_at)
    @input_files = @assignment.input_files
    @submissions = @assignment.submissions
    @rubric_items = @assignment.rubric_items
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
