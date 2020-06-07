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
    Dir.glob(@src_path.join('*.java')) do |file|
      ret = exec('javac',
                 '-d',
                 @bin_path,
                 '-cp',
                 @bin_path,
                 file)
      exec_ret[0] += (ret[0] + "\n\n") unless ret[0].empty?
      exec_ret[1] += (ret[1] + "\n\n") unless ret[1].empty?
    end
    if exec_ret[1].empty?
      flash.now[:success] = 'Compile successfully.'
      @console_output = 'Nothing wrong happened.'
    else
      flash.now[:error] = 'Error occurs during compilation. '\
                          'Please check the console output.'
      @console_output = exec_ret[1]
    end

    @action = 'compile'
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
      exec_ret = exec('java',
                      '-cp',
                      @bin_path,
                      params[:run][:junit].to_i.zero? ? '' : 'org.junit.runner.JUnitCore',
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
    params[:selected_checkstyle].each do |f|
      next if f[1].to_i.zero?

      filename = f[0]
      file_type = !filename.end_with?('Test.java') ? @src_path : @test_path
      filepath = file_type.join(File.basename(filename))
      stdout = exec(cs_path, filepath)[0].split("\n")

      stdout = stdout.grep(/#{filename}:.+/)
      stdout = stdout.grep_v(/is a magic number/) if params[:checkstyle_options][:ignore_magic_numbers].to_i == 1
      stdout = stdout.grep_v(/Missing a Javadoc comment/) if params[:checkstyle_options][:ignore_javadoc].to_i == 1
      puts stdout
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
    uploaded_file = params[:file]
    if uploaded_file.nil?
      flash[:error] = 'No file selected.'
    else
      filename = uploaded_file.original_filename
      FileUtils.mkdir_p(@src_path)
      FileUtils.mkdir_p(@test_path)
      upload_to = !filename.end_with?('Test.java') ? @src_path : @test_path

      byte = uploaded_file.read
      if byte.empty?
        flash[:error] = 'File cannot be empty.'
      else
        File.open(upload_to.join(filename), 'wb') do |f|
          f.write(byte)
          flash[:success] = 'Upload successfully.'
        end
      end
    end
    redirect_to "/grading/#{@assignment_type}/#{@id}/prepare"
  end

  def delete_upload
    selected_delete = params[:selected_delete]
    if selected_delete.values.all? { |v| v.to_i.zero? }
      flash[:error] = 'Nothing to delete.'
    else
      selected_delete.each do |filename, checked|
        next if checked.to_i.zero?

        delete_from = !filename.end_with?('Test.java') ? @src_path : @test_path
        File.open(delete_from.join(filename), 'r') do |f|
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
    @src_path = @upload_root&.join('src')
    @test_path = @upload_root&.join('test')
    @bin_path = @upload_root&.join('bin')
    @action = params[:action]
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
