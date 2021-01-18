# frozen_string_literal: true

module Api
  class GradeItemsController < ApplicationController
    def show
      render json: GradeItem.find(params.require(:id)), serializer: GradeItemSerializer
    end
  end
end
