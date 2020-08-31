class SettingsController < ApplicationController
  def index
    begin
      DependenciesUtil.reload
    rescue StandardError => e
      flash[:error] = e
    end
  end

  def reload
    begin
      DependenciesUtil.reload
      flash[:info] = "Dependencies information updated."
    rescue StandardError => e
      flash[:error] = e
    end
    redirect_back(fallback_location: '/settings')
  end
end
