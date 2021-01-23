# frozen_string_literal: true

module Api
  module Rubrics
    module Items
      class BaseController < ApplicationController
        #   GET /rubrics/items/:id
        def show
          render json: ::Rubrics::Item::Base.find(params.require(:id))
        end

        #   GET /rubrics/items/:base_id/grade_items
        # rubocop:disable Naming/AccessorMethodName
        def get_grade_items
          render json: ::Rubrics::Item::Base.find(params.require(:base_id)).grade_items
        end

        #   DELETE /rubrics/items/:base_id/grade_items
        def delete_grade_items
          rubric_item = ::Rubrics::Item::Base.find(params.require(:base_id))
          rubric_item.grade_items.destroy_all
          render json: rubric_item.create_grade_items
        end
      end
    end
  end
end
