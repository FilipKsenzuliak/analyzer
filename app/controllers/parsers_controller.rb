class ParsersController < ApplicationController
	require 'grok-pure'
  respond_to :json, :html, :js
  add_flash_types :success, :warn
  autocomplete :parser, :name, :full => true

	def index
    @parser = Parser.new
		if params[:search]
      @parsers = Parser.search(params[:search]) 
    else
      @parsers = Parser.all
    end

    @tokens = []
    @groups = []

    @parsers.each do |item|
      if item[:expression].match(/%{.*}/)
        @groups << item
      else
        @tokens << item
      end
    end

    @groups.sort_by! {|item| item.name.downcase}
    @tokens.sort_by! {|item| item.name.downcase}
  end

  def show
  end

  # GET /parsers/new
  def new
    @parser = Parser.new
  end

  # GET /parsers/1/edit
  def edit
  	@parser = Parser.find(params[:id])
  end

  def form_save
    @parser = Parser.new(
                          name: params[:name],
                          expression: params[:expression],
                          blacklist: params[:blacklist],
                          source_group: params[:source_group]
                        )
    respond_to do |format|
      if @parser.save
        format.js # discover vzor a poslat do JS
        format.html { redirect_to '/parsers' , notice: 'Parser was successfully created.' }
        format.json { render :show, status: :created, location: @parser }
      else
        format.html { render :new }
        format.json { render json: @parser.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    @parser = Parser.new(parser_params)

    respond_to do |format|
      if @parser.save
        format.html { redirect_to '/parsers', notice: 'Parser was successfully created.' }
        format.json { render :show, status: :created, location: @parser }
      else
        format.html { render :new }
        format.json { render json: @parser.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
  	@parser = Parser.find(params[:id])
    patterns = Pattern.all
    pattern_names = []
    able = true

    patterns.each do |pattern|
      pattern_names << pattern.text
    end
    
    if pattern_names.include? '%{' + @parser.name.to_s + '}'
      able = false
    end

    respond_to do |format|
      if able
        if @parser.update(parser_params)
          format.html { redirect_to '/parsers', notice: 'Parser was successfully updated.' }
          format.json { render :show, status: :ok, location: @parser }
        else
          format.html { render :edit }
          format.json { render json: @parser.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to edit_parser_path(@parser), warn: "Can't update parser because it is present in pattern(s)" }
      end
    end
  end

  def destroy
    @parser = Parser.find(params[:id])
    patterns = Pattern.all
    pattern_names = []
    able = true

    patterns.each do |pattern|
      pattern_names << pattern.text
    end

    if pattern_names.include? '%{' + @parser.name.to_s + '}'
      able = false
    end

    respond_to do |format|
      if able
        if @parser.present?
          @parser.destroy
        end
        format.html { redirect_to parsers_url, notice: 'Parser was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to parsers_url, warn: "Can't destroy parser because it is present in pattern(s)" }
      end
    end
  end

  def export
    parsers = {}
    Parser.all.each do |parser|
      parsers[parser.name] = {
                              expression: parser.expression,
                              blacklist: parser.blacklist,
                              source_group: parser.source_group
                             }
    end
    data = JSON.pretty_generate(parsers)

    file = "parsers.json"
    File.open(file, "w"){ |f| f << data }
    send_file( file )
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def parser_params
      params.require(:parser).permit(:name, :expression, :blacklist, :source_group)
    end 
end
