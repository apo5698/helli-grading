class TsFilesController < ApplicationController
  before_action :set_ts_file, only: [:show, :edit, :update, :destroy]

  # GET /ts_files
  # GET /ts_files.json
  def index
    @ts_files = TsFile.all
  end

  # GET /ts_files/1
  # GET /ts_files/1.json
  def show
  end

  # GET /ts_files/new
  def new
    @ts_file = TsFile.new
  end

  # GET /ts_files/1/edit
  def edit
  end

  # POST /ts_files
  # POST /ts_files.json
  def create
    @ts_file = TsFile.new(ts_file_params)

    respond_to do |format|
      if @ts_file.save
        format.html { redirect_to @ts_file, notice: 'Ts file was successfully created.' }
        format.json { render :show, status: :created, location: @ts_file }
      else
        format.html { render :new }
        format.json { render json: @ts_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ts_files/1
  # PATCH/PUT /ts_files/1.json
  def update
    respond_to do |format|
      if @ts_file.update(ts_file_params)
        format.html { redirect_to @ts_file, notice: 'Ts file was successfully updated.' }
        format.json { render :show, status: :ok, location: @ts_file }
      else
        format.html { render :edit }
        format.json { render json: @ts_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ts_files/1
  # DELETE /ts_files/1.json
  def destroy
    @ts_file.destroy
    respond_to do |format|
      format.html { redirect_to ts_files_url, notice: 'Ts file was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_ts_file
    @ts_file = TsFile.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def ts_file_params
    params.fetch(:ts_file, {})
  end
end
