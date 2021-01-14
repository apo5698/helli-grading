class ProgramsController < AssignmentsViewController
  #  POST /courses/:course_id/assignments/:id/programs?name=#{name}
  def create
    name = params.require(:program).require(:name)
    Program.create!(name: name, assignment_id: @assignment.id)
    flash.notice = "Program #{name} added."
  rescue Assignment::ProgramExists => e
    flash.alert = e.message
  ensure
    redirect_back fallback_location: { action: :show }
  end

  #  DELETE /courses/:course_id/assignments/:id/programs?id=#{id}
  def destroy
    program = Program.find(params.require(:id))
    name = program.name
    program.destroy!
    flash.notice = "Program #{name} deleted."
    redirect_back fallback_location: { action: :show }
  end

  #  DELETE /courses/:course_id/assignments/:id/programs
  def destroy_all
    @assignment.programs.destroy_all
    flash.notice = 'All programs are deleted.'
    redirect_back fallback_location: { action: :show }
  end
end
