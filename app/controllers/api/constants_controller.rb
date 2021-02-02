# frozen_string_literal: true

# noinspection RailsI18nInspection
module Api
  class ConstantsController < ApplicationController
    def checkstyle
      render json: I18n.t('checkstyle').to_json
    end

    def zybooks
      render json: I18n.t('zybooks').to_json
    end
  end
end
