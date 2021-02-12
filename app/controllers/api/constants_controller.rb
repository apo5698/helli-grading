# frozen_string_literal: true

# noinspection RailsI18nInspection
module Api
  class ConstantsController < ApplicationController
    def zybooks
      render json: Config.get('zybooks').to_json
    end
  end
end
