class AnalyzerController < ApplicationController
	# requiring here since gem is called jls-grok and this also needs to be included
	require 'grok-pure'

	# example log: 2016-10-21 15:06:02 xksenzu MyProgram[13163]: 192.168.0.1
	# example log: 2016-10-21 15:06:02 xksenzu MyProgram[13163]: 192.168.0.1 
	
	
	def index
  end

  def analyze
  	@log_text = ''
  	@log_text = params[:log]
  	@pattern  = ''
  	@log_data = []

	  grok = Grok.new
		grok.add_patterns_from_file("#{Rails.root}/public/patterns/base")

		patterns = {}
		patterns['timestamp'] = "%{TIMESTAMP_ISO8601}"
		patterns['ip'] = "%{IP}"

		unless @log_text.nil?
			unmatched_data = @log_text.clone

			patterns.each do |name, expression|
				grok.compile(expression)
				# puts "Input: #{input}"
				# puts "Pattern: #{pattern}"
				# puts "Full: #{grok.expanded_pattern}"
				match = grok.match(@log_text)

				if match
					text = match.captures.values.first.first
					unmatched_data.slice! (text)
					@log_data << [name, text, 0, grok.expanded_pattern]
				end
			end

			unmatched_data.split(' ').each do |data|
				@log_data << ['unknown', data, 0, '']
			end

			@log_data.each do |data|
				@pattern += '<' + data[0] + '>'
			end
		end

		# @log_data = {}

  # 	# searching log text for known patterns
  # 	patterns_hash.each do |key, value|
		# 	match = Regexp.new(value).match(@log_text)

		# 	# store name of attribute as key with matched text, position and pattern
		# 	@log_data[key] = [match[0], match.begin(0), value] unless match.nil?
		# end

		# @log_data = @log_data.sort_by {|_key, value| value[1]}

		# @pattern = ''
		# @log_data.each do |key, value|
		# 	@pattern += '<' + key.to_s + '> '
		# end
		
  end
end
