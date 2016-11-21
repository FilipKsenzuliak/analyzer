class PatternsController < ApplicationController
  before_action :set_pattern, only: [:show, :edit, :update, :destroy]
  require 'pp'
  # GET /patterns
  # GET /patterns.json
  def index
    if params[:search]
      @patterns = Pattern.search(params[:search]).order(created_at: :desc)
    else
      @patterns = Pattern.all.order(created_at: :desc)
    end
  end

  # GET /patterns/1
  # GET /patterns/1.json
  def show
  end

  # GET /patterns/new
  def new
    @pattern = Pattern.new
  end

  # GET /patterns/1/edit
  def edit
  end

  # POST /patterns
  # POST /patterns.json
  def create
    @pattern = Pattern.new(pattern_params)

    respond_to do |format|
      if @pattern.save
        
        format.html { redirect_to '/patterns', notice: 'Pattern was successfully created.' }
        format.json { render :show, status: :created, location: @pattern }
      else
        format.js
        format.html { redirect_to '/patterns/new', notice: 'Pattern is already present in the database.' }
        format.json { render json: @pattern.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_with_log
    @pattern = Pattern.new(pattern_params)
    parsers = Parser.all
    parsers_names = []
    parts = @pattern[:text].split(/[\s|\/]/)
    @recognized = true
    @unknown = ''

    parsers.each do |parser|
      parsers_names << parser.name
    end
    
    parts.each do |part|
      pp '*****************'
      pp part
      unless parsers_names.include? part.gsub(/[\{\}\%]/, '')
        @unknown = part
        @recognized = false
      end
    end

    respond_to do |format|
      if @recognized
        if @pattern.save
          log = Log.new(text: params[:log], pattern_id: @pattern.id)
          log.save
          format.html { redirect_to '/patterns', notice: 'Pattern was successfully created.' }
          format.json { render :show, status: :created, location: @pattern }
        else
          format.js
          format.html { render :new }
          format.json { render json: @pattern.errors, status: :unprocessable_entity }
        end
      else
        format.js
      end
    end
  end

  # PATCH/PUT /patterns/1
  # PATCH/PUT /patterns/1.json
  def update
    respond_to do |format|
      if @pattern.update(pattern_params)
        format.html { redirect_to '/patterns', notice: 'Pattern was successfully updated.' }
        format.json { render :show, status: :ok, location: @pattern }
      else
        format.html { render :edit }
        format.json { render json: @pattern.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /patterns/1
  # DELETE /patterns/1.json
  def destroy
    @pattern.destroy
    respond_to do |format|
      format.html { redirect_to patterns_url, notice: 'Pattern was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pattern
      @pattern = Pattern.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pattern_params
      params.require(:pattern).permit(:text, :source)
    end
end
