class SynonymsController < ApplicationController
	add_flash_types :success, :warn
	def show
  end

  def new
    @synonym = Synonym.new
  end

  def edit
  end

	def destroy
    Synonym.find(params[:id]).destroy
    respond_to do |format|
    	format.html { redirect_to '/taxonomy', warn: 'Synonym was successfully deleted.' }
    end
  end
end
