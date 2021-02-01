# frozen_string_literal: true

module Api
  class ConstantsController < ApplicationController
    def checkstyle
      # noinspection RailsI18nInspection
      render json: I18n.t('checkstyle').to_json
    end
  end
end
