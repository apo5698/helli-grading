class SettingsController < ApplicationController
  before_action lambda {
    @title = controller_name.classify.pluralize
    @dependencies = Dependency.all.map { |d| d.attributes.except('id', 'path', 'created_at', 'updated_at') }
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
end
