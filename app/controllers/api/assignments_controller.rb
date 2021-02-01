# frozen_string_literal: true

module Api
  class AssignmentsController < ApplicationController
    #  GET https://api.helli.app/assignments/:assignment_id/rubrics/items
    def rubrics_items
      assignment = Assignment.find(params.require(:assignment_id))
      render json: assignment.rubric_items
    end
  end
end
