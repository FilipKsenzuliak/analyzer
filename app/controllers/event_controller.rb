class EventController < ApplicationController
	def index
    pattern = session[:pattern]
    log = session[:log]
    @data = []

    p '**************************'
    p log
    p pattern

    grok = Grok.new
    parsers = Parser.all
    parsers.each do |p|
      grok.add_pattern(p.name, p.expression)
    end

    grok.compile(pattern)
    m = grok.match(log)

    check = {}
    pattern.split(' ').each do |part|
      part.gsub!(/[\{\}\%]/, '')

      # check if there are more parts with same name and match them appropriately
      if check.key?(part)
        check[part] += 1
        capture = m.captures[part][check[part]]
      else
        check[part] = 0
        if m
          capture = m.captures[part].first
        else
          capture = '<UNKNOWN>'
        end
      end
      @data << { name: part, text: capture }
    end

	end
end
