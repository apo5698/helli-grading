class SubmissionsController < ApplicationController
  def index
    @submissions = Submission.where(assignment_id: params[:assignment_id])
  end

  def upload; end
  def replace; end
  def download; end
  def remove; end
end
