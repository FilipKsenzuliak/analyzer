class ParsersController < ApplicationController
	require 'grok-pure'
  respond_to :json, :html, :js

	def index
		@parser = Parser.new
		@parsers = Parser.all

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

  # GET /parsers/new
  def new
    @parser = Parser.new
  end

  # GET /parsers/1/edit
  def edit
  	@parser = Parser.find(params[:id])
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
    respond_to do |format|
      if @parser.update(parser_params)
        format.html { redirect_to '/parsers', notice: 'Parser was successfully updated.' }
        format.json { render :show, status: :ok, location: @parser }
      else
        format.html { render :edit }
        format.json { render json: @parser.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @parser = Parser.find(params[:id])
    if @parser.present?
      @parser.destroy
    end

    respond_to do |format|
      format.html { redirect_to parsers_url, notice: 'Parser was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def parser_params
      params.require(:parser).permit(:name, :expression, :blacklist, :source_group)
    end  
end
