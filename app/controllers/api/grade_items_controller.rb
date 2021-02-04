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
      unless attachment
        raise ActiveRecord::RecordNotFound,
              "Couldn't find attachment of GradeItem with 'id'=#{params.require(:grade_item_id)}"
      end

      render json: attachment, serializer: ActiveStorageAttachmentSerializer
    end

    #  PUT https://api.helli.app/grade_items/:id
    def update
      render json: GradeItem.find(params.require(:id)).run(params), serializer: GradeItemSerializer
    end
  end
end
