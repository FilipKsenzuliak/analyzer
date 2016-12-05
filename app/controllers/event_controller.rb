class EventController < ApplicationController
  require 'csv'
  require 'pp'

	def index
    pattern = session[:pattern]
    log = session[:log]
    @data = []

    ## parse data from log management
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

    @event_data = find_event(log) 
	end # def index

  def find_event(log)
    events = Event.all
    data = {}
    events.each do |event|
      data[event.clasification] = event.tag if log.include? event.tag
    end
    data
  end # def find_event

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

  def show
  end

  def new
    @event = Event.new
  end

  def edit
  end

  def create
    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
        
        format.html { redirect_to '/events', notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.js
        format.html { redirect_to '/events/new', notice: 'Event is already present in the database.' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to '/events', notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      event.require(:event).permit(:tag, :clasification, :description)
    end

end
