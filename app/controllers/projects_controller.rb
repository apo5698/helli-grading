class ProjectsController < ApplicationController
  def index
    @controller = params[:controller]
    render '/grading/index'
  end
end
