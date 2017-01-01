class LogsController < ApplicationController
  require 'grok-pure'
  before_action :set_log, only: [:show, :edit, :update, :destroy]
  respond_to :json, :html, :js

  # GET /logs
  # GET /logs.json
  def index
    if params[:search]
      @logs = Log.search(params[:search]) 
    else
      @logs = Log.all
    end
  end

  # GET /logs/1
  # GET /logs/1.json
  def show
  end

  # GET /logs/new
  def new
    @log = Log.new
  end

  # GET /logs/1/edit
  def edit
  end

  # POST /logs
  # POST /logs.json
  def create
    @log = Log.new(log_params)

    respond_to do |format|
      if @log.save
        format.html { redirect_to @log, notice: 'Log was successfully created.' }
        format.json { render :show, status: :created, location: @log }
      else
        format.html { render :new }
        format.json { render json: @log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /logs/1
  # PATCH/PUT /logs/1.json
  def update
    respond_to do |format|
      if @log.update(log_params)
        format.html { redirect_to @log, notice: 'Log was successfully updated.' }
        format.json { render :show, status: :ok, location: @log }
      else
        format.html { render :edit }
        format.json { render json: @log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /logs/1
  # DELETE /logs/1.json
  def destroy
    @log.destroy
    respond_to do |format|
      format.html { redirect_to logs_url, notice: 'Log was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def tokens
    @patterns = {}
    respond_to do |format|
      format.js
    end
  end

  def groups
    @patterns = {}
    respond_to do |format|
      format.js
    end
  end

  def export
    logs = []
    Log.all.each do |log|
      pattern = Pattern.find_by_id(log.pattern_id)
      text = source = ''
      tags = []

      unless pattern == nil
        text = pattern.text
        source = pattern.source
        pattern.tags.map {|x| tags.push(x.text)}
      
      
        grok = Grok.new
        parsers = Parser.all
        parsers.each do |p|
          grok.add_pattern(p.name, p.expression)
        end

        grok.compile(pattern.text)
        m = grok.match(log.text)

        log_data = {}
        pattern.text.split(' ').each_with_index do |part, i|
          part.gsub!(/[\{\}\%]/, '')
            if m
              capture = m.captures[part].first
            else
              capture = '<UNKNOWN>'
            end
          log_data[part] = capture
        end
      end

      logs << {
                log_data: log_data,
                pattern: text,
                source: source,
                tags: tags
              }
    end
    data = JSON.pretty_generate(logs)

    file = "logs.json"
    File.open(file, "w"){ |f| f << data }
    send_file( file )
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_log
      @log = Log.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def log_params
      params.require(:log).permit(:text, :label)
    end
end
