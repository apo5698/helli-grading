class GradingController < ApplicationController
  def index; end

  def show
    @params = params
    @step = params[:step].to_i
    @step = 1 if @step.zero?
  end

  def update; end
end
