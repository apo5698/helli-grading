class SettingsController < ApplicationController
  before_action lambda {
    @title = controller_name.classify.pluralize
    @dependencies = Helli::Dependency.public_dependencies
  }

  #  GET /settings/json
  def json
    send_data(
      @dependencies.to_json,
      filename: 'dependencies.json',
      type: 'application/json',
      disposition: :inline
    )
  end

  def show; end
end
