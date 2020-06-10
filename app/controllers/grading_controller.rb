require 'colorize'
require 'fileutils'
require 'open3'

class GradingController < ApplicationController
  before_action :set_variables

  def index
    redirect_to '/grading/exercises'
  end

  def create
    assignment = Assignment.create(assignment_params)
    if assignment
      type = assignment.type.downcase
      type = type.pluralize if type != 'homework'
      assignment_path = @user_root.join(type, assignment.id.to_s)
      if type != 'homework'
        FileUtils.mkdir_p assignment_path.join('bin')
        FileUtils.mkdir_p assignment_path.join('src')
        FileUtils.mkdir_p assignment_path.join('test')
        FileUtils.mkdir_p assignment_path.join('test_files')
      end

      flash[:success] = "#{assignment.name} has been successfully created"
    else
      flash[:error] = "Error occurred when creating #{assignment.name}"
    end
    redirect_to last_page(assignment.type)
  end

  def show; end

  def prepare
    render '/grading/show'
  end

  def compile
    render 'grading/show'
  end

  def compile_all
    exec_ret = Array.new(2, '')
    files = Dir.glob(@src_path.join('*.java'))
    if files.empty?
      flash[:error] = 'No file found.'
    else
      cp_path = @bin_path.to_s
      cp_path << ":#{@public_lib_path.join('junit', '*')}" if params[:compile][:options][:junit].to_i == 1

      files.each do |file|
        ret = exec('javac',
                   '-d',
                   @bin_path,
                   '-cp',
                   cp_path,
                   file,
                   params[:compile][:arg])
        exec_ret[0] << (ret[0] + "\n\n") unless ret[0].empty?
        exec_ret[1] << (ret[1] + "\n\n") unless ret[1].empty?
      end
      if exec_ret[1].empty?
        flash.now[:success] = 'Compile successfully.'
        @console_output = 'Nothing wrong happened.'
      else
        flash.now[:error] = 'Error occurs during compilation. '\
                            'Please check the console output.'
        @console_output = exec_ret[1]
      end
    end

    @action = 'compile'
    compile
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

      exec_ret = exec('java',
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
      stdout = exec(cs_path, filepath)[0].split("\n")

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

  def summary
    render '/grading/show'
  end

  def upload
    if params[:upload].nil?
      flash[:error] = 'No file selected.'
    else
      uploaded_file = params[:upload][:file]
      byte = uploaded_file.read
      if byte.empty?
        flash[:error] = 'File cannot be empty.'
      else
        filename = uploaded_file.original_filename
        upload_to = !filename.end_with?('Test.java') ? @src_path : @test_path
        File.open(upload_to.join(filename), 'wb') do |f|
          f.write(byte)
          flash[:success] = 'Upload successfully.'
        end
      end
    end
    redirect_to "/grading/#{@assignment_type}/#{@id}/prepare"
  end

  def delete_upload
    delete_files = params[:delete_upload]
    if delete_files.values.all? { |v| v.to_i.zero? }
      flash[:error] = 'Nothing to delete.'
    else
      delete_files.each do |filename, checked|
        next if checked.to_i.zero?

        delete_from = !filename.end_with?('Test.java') ? @src_path : @test_path
        filepath = delete_from.join(filename)
        File.open(delete_from.join(filepath), 'r') do |f|
          File.delete(f)
        end
      end
      flash[:success] = 'File(s) deleted.'
    end
    redirect_to "/grading/#{@assignment_type}/#{@id}/prepare"
  end

  private

  def last_page(type)
    if type == 'Homework'
      "/grading/#{type.downcase}"
    else
      "/grading/#{type.downcase.pluralize}"
    end
  end

  def set_variables
    if params[:exercise_id]
      @assignment_type = 'exercises'
      @id = params[:exercise_id]
    elsif params[:project_id]
      @assignment_type = 'projects'
      @id = params[:project_id]
    elsif params[:homework_id]
      @assignment_type = 'homework'
      @id = params[:homework_id]
    end
    @action = params[:action]
    set_paths
  end

  def set_paths
    public_path = Rails.root.join('public')
    @public_lib_path = public_path.join('lib')
    @user_root = public_path.join('uploads', 'users', session[:user].email)
    @upload_root = @user_root.join(@assignment_type, @id) if @id
    @src_path = @upload_root&.join('src')
    @test_path = @upload_root&.join('test')
    @bin_path = @upload_root&.join('bin')
    @lib_path = @upload_root&.join('lib')
  end

  def assignment_params
    params.require(:assignment).permit(:name, :type, :term,
                                       :course, :section, :description)
  end

  def exec(cmd, *args)
    args = args.join(' ')
    puts "#{'exec>'.bold} #{cmd.green} #{args}"

    full_cmd = "#{cmd} #{args}"
    output = []
    Open3.popen3(full_cmd) do |_, stdout, stderr, _|
      output = [stdout.read.gsub(%r{[/\w]+/}, '').strip,
                stderr.read.gsub(%r{[/\w]+/}, '').strip]
    end
    puts "  #{'stdout:'.magenta.bold} #{output[0].gsub("\n", "\n#{' ' * 10}")}"
    puts "  #{'stderr:'.magenta.bold} #{output[1].gsub("\n", "\n#{' ' * 10}")}"
    output
  end
end
