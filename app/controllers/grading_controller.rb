require 'colorize'
require 'json'
require 'open3'

class GradingController < ApplicationController
  before_action :set_for_assignments
  before_action :set_for_assignment, only: %w[prepare compile compile_selected run run_selected checkstyle checkstyle_run summary upload delete_upload]

  def checkstyle
    render '/grading/show'
  end

  def checkstyle_run
    cs_path = '~/cs-checkstyle/checkstyle'
    @cs_count = {}
    params[:checkstyle][:files]&.each do |f|
      next if f[1].to_i.zero?

      filename = f[0]
      file_type = !filename.end_with?('Test.java') ? @src_path : @test_path
      filepath = file_type.join(File.basename(filename))
      stdout = GradingHelper.exec(cs_path, filepath)[0].split("\n")

      stdout = stdout.grep(/#{filename}:.+/)
      options = params[:checkstyle][:options]
      stdout = stdout.grep_v(/is a magic number/) if options[:ignore_magic_numbers].to_i == 1
      stdout = stdout.grep_v(/Missing a Javadoc comment/) if options[:ignore_javadoc].to_i == 1
      @cs_count[:"#{filename}"] = stdout.count
    end
    flash.now[:error] = 'No file selected.' if @cs_count.empty?
    @action = 'checkstyle'
    checkstyle
  end

  def compile
    render 'grading/show'
  end

  def compile_selected
    files = params[:compile].except('options')
                            .except('arg')
                            .select { |_, v| v.to_i == 1 }
                            .keys
                            .map { |f| File.join(@upload_root, 'submissions', f) }
    files = files.first if files.one?
    begin
      @console_output = GradingHelper.compile(files,
                                              to: '.',
                                              lib: @public_lib_path,
                                              options: params[:compile][:options],
                                              args: params[:compile][:arg])[:stderr]
      puts @console_output
      if @console_output.empty?
        flash.now[:success] = 'Compile successfully.'
      else
        flash.now[:error] = 'Compile failed. Please check console output below.'
      end
    rescue StandardError => e
      flash.now[:error] = e.message
    end

    @action = 'compile'
    compile
  end

  def create
    @assignment = Assignment.create(assignment_params)
    @messages = @assignment.errors.full_messages
    assignment_type = assignment_params[:type].downcase
    if @messages.blank?
      if assignment_type != 'Homework'
        assignment_path = @user_root.join(assignment_type.downcase.pluralize, @assignment.id.to_s)
        FileHelper.create dir: assignment_path.join('submissions')
      end
      flash[:success] = "#{@assignment.name} has been successfully created."
    else
      flash[:modal_error] = @messages.uniq.reject(&:blank?).join(".\n") << '.'
    end
    redirect_to action: 'index', assignment_type => assignment_params.to_h
  end

  def delete_upload
    files = params[:delete_upload].select { |_, v| v.to_i == 1 }
                                  .keys
                                  .map { |f| File.join(@upload_root, f) }
    files = files.first if files.one?
    begin
      GradingHelper.delete! files
      FileHelper.remove_dir @upload_root.join('submissions')
      flash[:success] = 'Delete successfully.'
    rescue StandardError => e
      flash[:error] = e.message
    end
    redirect_to "/grading/#{@assignment_type}/#{@id}/prepare"
  end

  def destroy
    assignment = Assignment.find(params[:id])
    name = assignment.name
    @id = assignment.id
    assignment.destroy
    flash[:success] = "#{name} has been successfully deleted"
    redirect_to action: 'index'
  end

  def edit
    @assignment = Assignment.find(params[:id])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def index(the_class)
    @assignments = the_class.all
    if flash[:modal_error]
      @assignment = Assignment.find_by(id: params[:assignment_id])
      @assignment = the_class.new unless @assignment
      @assignment.assign_attributes(assignment_params)
    end
  end

  def new(the_class)
    @assignment = the_class.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def prepare
    render '/grading/show'
  end

  def run
    render '/grading/show'
  end

  def run_selected
    file = params[:run][:file]
    if file.nil?
      flash.now[:error] = 'No file selected.'
    else
      cp_path = @bin_path.to_s
      junit_pkg = ''
      if params[:run][:options][:junit].to_i == 1
        cp_path << ":#{@public_lib_path.join('junit', '*')}"
        junit_pkg = 'org.junit.runner.JUnitCore'
      end

      exec_ret = GradingHelper.exec('java',
                                    '-cp',
                                    cp_path,
                                    junit_pkg,
                                    file.gsub('.class', ''),
                                    params[:run][:arg])
      if exec_ret[1].empty?
        flash.now[:success] = 'Run successfully.'
      else
        flash.now[:error] = 'Error occurs during running. '\
                            'Please check the console output.'
      end
      @console_output = exec_ret[0] + exec_ret[1]
    end

    @action = 'run'
    run
  end

  def summary
    render '/grading/show'
  end

  def update
    @assignment = Assignment.find(params[:id])
    @assignment.update_attributes(assignment_params)
    assignment_type = assignment_params[:type].downcase
    messages = @assignment.errors.full_messages
    if messages.blank?
      flash[:success] = "#{@assignment.name} has been successfully updated."
    else
      flash[:modal_error] = messages.uniq.reject(&:blank?).join(".\n") << '.'
    end
    redirect_to action: 'index', assignment_type => assignment_params, assignment_id: params[:id]
  end

  def upload
    if params[:upload].nil?
      flash[:error] = 'No file selected.'
    else
      uploaded_file = params[:upload][:file]
      # Why add this line?
      # uploaded_file = uploaded_file.first if uploaded_file.length == 1
      begin
        GradingHelper.upload(uploaded_file, @upload_root)
        flash[:success] = 'Upload successfully.'
      rescue StandardError => e
        flash[:error] = e.message
      end
      uploaded_file.each do |f|
        filename = f.original_filename
        GradingHelper.unzip(@upload_root.join(filename), @upload_root.join('submissions')) if filename.match(/.+\.zip/)
      end
    end

    redirect_to "/grading/#{@assignment_type}/#{@id}/prepare"
  end

  private

  def remove_subdirectories(base_path)
    FileHelper.remove base_path
  end

  def set_for_assignment
    @id = params[@assignment_type.singularize + '_id']
    @assignment = Assignment.find(@id)

    @upload_root = @user_root.join(@assignment_type, @id)
    @src_path = @upload_root.join('src')
    @test_path = @upload_root.join('test')
    @bin_path = @upload_root.join('bin')
    @lib_path = @upload_root.join('lib')

    @students = FileHelper.dir_names(@upload_root.join('submissions'))
  end

  def set_for_assignments
    @assignment_type = params[:controller]
    @action = params[:action]

    public_path = Rails.root.join('public')
    @public_lib_path = public_path.join('lib')
    @user_root = public_path.join('uploads', 'users', session[:user].email)
  end
end
