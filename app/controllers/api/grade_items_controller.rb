# frozen_string_literal: true

module Api
  class GradeItemsController < ApplicationController
    #  GET https://api.helli.app/grade_items/:id
    def show
      render json: GradeItem.find(params.require(:id)), serializer: GradeItemSerializer
    end

    #  GET https://api.helli.app/grade_items/:id/attachment
    def attachment
      attachment = GradeItem.find(params.require(:grade_item_id)).attachment

      if attachment
        render json: attachment, serializer: ActiveStorageAttachmentSerializer
      else
        render json: nil, status: :not_found
      end
    end

    #  PUT https://api.helli.app/grade_items/:id
    def update
      render json: GradeItem.find(params.require(:id)).run(params), serializer: GradeItemSerializer
    end
  end
end
