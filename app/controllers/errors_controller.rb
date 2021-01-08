class ErrorsController < ApplicationController
  layout 'pre_application'

  skip_before_action :authenticate_user!

  def show
    status = params[:status] || 500
    render status.to_s, status: status
  end
end
