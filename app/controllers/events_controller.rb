class EventsController < ApplicationController
  require 'csv'
  require 'pp'
  require 'grok-pure'
  add_flash_types :success, :warn

	def index
    @pattern = session[:pattern]
    @log = session[:log]
    @pattern_source = Pattern.where("text LIKE :search", search: "#{session[:pattern]}%").first 
    if @pattern_source == nil
      @warning = "WARNING: log pattern is not recognized. You won't be able to save event pattern! (To resolve this, process valid log pattern)"
    else
      @source = @pattern_source.source 
    end
    @data = []

    ## parse data from log management
    if session[:log] && session[:pattern]
      grok = Grok.new
      parsers = Parser.all
      parsers.each do |p|
        grok.add_pattern(p.name, p.expression)
      end

      grok.compile(@pattern)
      m = grok.match(@log)

      check = {}

      if @pattern_source.try(:event_pattern)
        event =  @pattern_source.event_pattern.split(' ') 
      else 
        event = []
      end
      @pattern.split(' ').each_with_index do |part, i|
        part.gsub!(/[\{\}\%]/, '')

        if false#check.key?(part)
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
        name = part
        name = event[i] if @pattern_source.try(:event_pattern)
        @data << { name: part, text: capture, event: name }
      end
    end

    if session[:log]
      @event_data = find_event(@log) 
    end
	end # def index

  def find_event(log)
    events = Event.all
    data = {}
    events.each do |event|
      data[event.clasification] = event.tag if log =~ /\b#{event.tag}\b/i
      event.synonyms.each do |synonym|
        data[event.clasification] = event.tag if log =~ /\b#{synonym.text}\b/i
      end
    end
    data
  end # def find_event

  def taxonomy
    if params[:search]
      @events = Event.search(params[:search]) 
    else
      @events = Event.all
    end
  end # def taxonomy

  def save_synonym
    @event = Event.new
    synonym = Synonym.new(text: params[:text], event_id: params[:id])

    respond_to do |format|
      if synonym.save
        format.html { redirect_to '/taxonomy', notice: 'Synonym was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.js
        format.html { redirect_to '/events/new', notice: 'Synonym is already present in the database.' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def save_event
    pattern = Pattern.where("text LIKE :search", search: "#{session[:pattern]}%").first
    pattern.update_attributes(event_pattern: params[:event_pattern])

    data = {:message => "Success"}
    render :json => data, :status => :ok
  end

  def save_tag
    pattern = Pattern.where("text LIKE :search", search: "#{session[:pattern]}%").first

    tag = Tag.new(text: params[pattern.text][:tag], pattern_id: pattern.id)
    respond_to do |format|
      if tag.save
        format.html { redirect_to '/event', notice: 'Tag was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.js
        format.html { redirect_to '/event', notice: 'Tag is already present in the database.' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

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
