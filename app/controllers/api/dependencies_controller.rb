# frozen_string_literal: true

module Api
  class DependenciesController < ApplicationController
    def show
      render json: Dependency.public_dependencies
    end
  end
end
