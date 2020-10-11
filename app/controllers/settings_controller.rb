class SettingsController < ApplicationController
  def index
    Dependency.load('config/dependencies.yml')
    @dependencies = Dependency.all
  end
end
