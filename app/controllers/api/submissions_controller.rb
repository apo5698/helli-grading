# frozen_string_literal: true

module Api
  class SubmissionsController < ApplicationController
    def show
      render json: Submission.find(params.require(:id)), serializer: ActiveStorageAttachmentSerializer
    end
  end
end
