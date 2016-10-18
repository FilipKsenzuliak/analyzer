class AnalyzerController < ApplicationController

	# example log: Nov 21 17:27:53 xksenzu MyProgram[13163]: 192.168.0.1
	@text = ''
	
	def index
  end

  def analyze
  	@text = params[:log]
  	@log_parts = @text.split(' ')
  end
end
