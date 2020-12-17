class GradingController < AssignmentsViewController
  before_action -> { @title = 'Automated Grading' }

  before_action lambda {
    @rubric_item = RubricItem.find(params.require(:id))
    @grade_items = @rubric_item.grade_items.presence

    @dependencies ||= Helli::Dependency.public_dependencies
    @status_colors ||= {
      inactive: :light,
      success: :success,
      resolved: :info,
      unresolved: :danger,
      error: :error,
      no_submission: :warning
    }
    @checkstyle_rules = RubricItem::Checkstyle::RULES
  }, except: :index

  #  GET /courses/:course_id/assignments/:assignment_id/grading
  def index
    if @submissions.present? && @rubric_items.present?
      redirect_to action: :show, id: @assignment.rubric_items.first.id
      return
    end

    messages = []

    if @submissions.empty?
      messages << 'No submission uploaded. '\
                  "#{helpers.link_to 'Upload a submission zip file',
                                     course_assignment_submissions_path(@course, @assignment)}".html_safe
    elsif @rubric_items.empty?
      messages << 'No rubric specified. '\
                  "#{helpers.link_to 'Create a rubric',
                                     course_assignment_rubrics_path(@course, @assignment)}".html_safe
    end

    flash_errors messages
  end

  #  GET /courses/:course_id/assignments/:assignment_id/grading/:id
  def show
    if @grade_items.blank?
      flash[:error] = 'Rubrics not completed.'
      redirect_back fallback_location: ''
      return
    end

    respond_to do |format|
      format.html { render 'show' }
    end
  end

  #  PUT /courses/:course_id/assignments/:assignment_id/grading/:id
  def update
    if @grade_items.empty?
      flash[:error] = 'The rubric has not been completed. '\
                      "#{helpers.link_to 'Complete',
                                         course_assignment_rubrics_path(@course, @assignment)}.".html_safe
      redirect_back fallback_location: { action: :show }
      return
    end

    options = params.require(:options).permit!.to_h

    threads = []
    threads_count = ENV.fetch('AUTOGRADING_THREADS', ENV.fetch('RAILS_MAX_THREADS', 5)).to_i
    # false: do not fill arrays with nil
    @grade_items.in_groups(threads_count, false).each do |items|
      threads << Thread.new do
        items.each do |item|
          item.run(options)
        ensure
          ActiveRecord::Base.connection_pool.release_connection
        end
      end
    end
    threads.each(&:join)

    respond_to do |format|
      format.js { flash.now[:success] = "Run #{@rubric_item} complete." }
    end
  end

  #  DELETE /courses/:course_id/assignments/:assignment_id/grading/:id
  def destroy
    id = params.require(:id)
    GradeItem.where(rubric_id: id).destroy_all
    title = Rubric.find(id)

    flash[:success] = "Grading results for #{title} has been reset."
    redirect_back fallback_location: { action: :show }
  end
end
