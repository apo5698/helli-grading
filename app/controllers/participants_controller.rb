class ParticipantsController < AssignmentsViewController
  #  POST /courses/:course_id/assignments/:assignment_id/participants
  def create
    record = params.require(:participant)

    if record.is_a?(Array)
      record.each { |r| Participant.create_from_moodle!(@assignment.id, r) }
      flash.notice = "Moodle grade worksheet uploaded. (#{record.count} participants)"
    else
      participant = Participant.create_from_moodle!(@assignment.id, record)
      render json: participant
    end
  end

  #  PUT /courses/:course_id/assignments/:assignment_id/participants
  def update
    # All grade items have to be resolved before updating
    flash.notice = 'Grades updated.'
  ensure
    redirect_back fallback_location: { action: :index }
  end

  #  DELETE /courses/:course_id/assignments/:assignment_id/participants/:id
  def destroy
    Participant.find(params.require(:id)).destroy
  end

  #  DELETE /courses/:course_id/assignments/:assignment_id/participants
  def destroy_all
    Participant.where(assignment_id: @assignment.id).destroy_all
  end
end
