class CoursesController < ApplicationController
  def index
    @courses = Course.all
  end

  def new; end
  def create; end
  def share; end
  def update; end
  def destroy; end
  def show; end
  def show_share; end
end
