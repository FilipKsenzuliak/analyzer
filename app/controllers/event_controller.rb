class EventController < ApplicationController
  require 'csv'

	def index
    pattern = session[:pattern]
    log = session[:log]
    @data = []

    if session[:log] && session[:pattern]
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

	end # def index

  def taxonomy
    @events = Event.all

    # CSV.foreach(File.path(Rails.root.join('public', 'patterns', 'taxonomy.csv'))) do |row|
    #   event_data = row[0].split(';')
    #   event = Event.new(
    #                     :tag => event_data[0],
    #                     :clasification => event_data[1],
    #                     :description => event_data[2],
    #                     :original => true 
    #                    )
    #   event.save
    # end
  end # def taxonomy

end
