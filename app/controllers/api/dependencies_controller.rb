# frozen_string_literal: true

module Api
  class DependenciesController < ApplicationController
    def index
      render json: Dependency.public_dependencies
    end

    def show
      render json: Dependency.find_by(name: params.require(:name))
    end
  end
end
