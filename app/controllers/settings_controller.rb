class SettingsController < ApplicationController
  before_action lambda {
    @dependencies = Dependency.all.map do |d|
      d.attributes.except('id', 'path', 'created_at', 'updated_at')
    end
  }

  def json
    send_data(
      @dependencies.to_json,
      filename: 'dependencies.json',
      type: 'application/json',
      disposition: :inline
    )
  end
end
