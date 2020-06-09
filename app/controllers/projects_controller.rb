class ProjectsController < ApplicationController
  def index
    @controller = params[:controller]
    @assignments = Project.all
    @assignment = Project.new
    render '/grading/index'
  end
end
