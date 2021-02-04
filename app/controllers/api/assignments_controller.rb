# frozen_string_literal: true

module Api
  class AssignmentsController < ApplicationController
    #  GET https://api.helli.app/assignments/:assignment_id/rubrics/items
    def rubrics_items
      assignment = Assignment.find(params.require(:assignment_id))
      render json: assignment.rubric_items
    end

    #  POST https://api.helli.app/assignments/:assignment_id/zybooks
    def zybooks
      csv = params.require(:_json)
      csv.each do |record|
        participant = Participant.find_by(
          assignment_id: params.require(:assignment_id),
          email_address: record[:email]
        )
        Redis.current.set(participant.zybooks_redis_key, record[:total])
      end

      render status: :ok
    rescue Redis::BaseError => e
      render plain: e.message, status: :unprocessable_entity
    end
  end
end
