require 'colorize'
require 'fileutils'
require 'open3'

class GradingController < ApplicationController
  before_action :set_variables

  def index; end

  def show; end

  def prepare
    render '/grading/show'
  end

  def compile
    render 'grading/show'
  end

  def compile_all
    exec_ret = Array.new(2, '')
    bin_path = @upload_root.join('bin')
    Dir.glob(@upload_root.join('src').join('*.java')) do |file|
      ret = exec("javac -d #{bin_path} -cp #{bin_path}", file)
      exec_ret[0] += ret[0]
      exec_ret[1] += ret[1]
    end

    if exec_ret[1].empty?
      flash.now[:success] = 'Compile successfully.'
      @console_output = 'Nothing wrong happened.'
    else
      flash.now[:error] = 'Error occurs during compilation. '\
                      'Please check the console output.'
      @console_output = exec_ret[1]
    end

    @action = "compile"
    compile
  end

  def run
    render '/grading/show'
  end

  def run_selected
    file = params[:file]
    if file.nil?
      flash.now[:error] = 'No file selected.'
    else
      exec_ret = exec("java -cp #{@upload_root.join('bin')}", file.gsub('.class', ''))
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
    ignore = params[:options][:ignore]
    params[:filepaths].each do |f|
      next if f[1].to_i.zero?

      filename = File.basename(f[0])
      ret = exec(cs_path, f[0])[0]
      @cs_count[:"#{filename}"] = if ignore.to_i.zero?
                                    ret.scan(/#{filename}:/).count
                                  else
                                    ret.scan(/^((?!magic number).)*$/).count - 4
                                  end
    end
    flash.now[:error] = 'No file selected.' if @cs_count.empty?
    @action = 'checkstyle'
    checkstyle
  end

  def summary
    render '/grading/show'
  end

  def upload
    uploaded_file = params[:file]
    if uploaded_file.nil?
      flash[:error] = 'No file selected.'
    else
      filename = uploaded_file.original_filename
      src_path = @upload_root.join('src')
      test_path = @upload_root.join('test')
      FileUtils.mkdir_p(src_path)
      FileUtils.mkdir_p(test_path)
      upload_to = !filename.end_with?('Test.java') ? src_path : test_path

      File.open(upload_to.join(filename), 'wb') do |f|
        if f.write(uploaded_file.read).zero?
          flash[:error] = 'File cannot be empty.'
        else
          flash[:success] = 'Upload successfully.'
        end
      end
    end
    redirect_to "/grading/#{@assignment_type}/#{@id}/prepare"
  end

  def delete_upload
    files_to_be_deleted = params[:filepaths]
    if files_to_be_deleted.nil?
      flash[:error] = 'Nothing to delete.'
    else
      params[:filepaths].each do |filepath, checked|
        next if checked.to_i.zero?

        File.open(filepath, 'r') do |f|
          File.delete(f)
        end
      end
      flash[:success] = 'File(s) deleted.'
    end
    redirect_to "/grading/#{@assignment_type}/#{@id}/prepare"
  end

  private

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
    @upload_root = Rails.root.join('public', 'uploads', @assignment_type, @id) if @id
    @action = params[:action]
  end

  def exec(cmd, filename)
    full_cmd = "#{cmd} #{filename}"
    puts "Running #{full_cmd.gsub(Rails.root.to_s, '').green}"
    Open3.popen3(full_cmd) do |_, stdout, stderr, _|
      [stdout.read.gsub(filename, File.basename(filename)),
       stderr.read.gsub(filename, File.basename(filename))]
    end
  end
end
