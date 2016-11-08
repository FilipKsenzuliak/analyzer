class AnalyzerController < ApplicationController
  # requiring here since gem is called jls-grok and this also needs to be included
  require 'grok-pure'
  require 'pp'

  # example log: 2016-10-21 15:06:02 xksenzu MyProgram[13163]: 192.168.0.1
  # example log: 01/20/2016 06:15:05.85 w3wp.exe (0x5154) 03194 SharePoint Foundation Micro Trace uls4 Medium Micro Trace Tags: (none) 20fa569d-e927-7055-3239-2cc8d3f9a2b7 
  
  # OSETRIT AK SA V LOGU VYSKYTUJE VIAC KRAT TO ISTE SLOVO TAK JEHO POZICIU
  # KED TEXT OBSAHUJE LEN ZNAKY ALEBO CISLA TAK JE TO PRAVDEPODOBNE NIC => MOZEM ZGRUPNUT
  def index
  end

  # def group
  #   text = params[:email]
  #   respond_to do |format|
  #     format.html { render action: 'index' }
  #     format.json { render json: true }
  #   end
    # $.ajax 'analyzer/group', 
    # type: "GET",
    # dataType: "JSON",
    # data: 
    #   email: 'niecoo'
    # success: (data) ->
    #   console.log(data)
  # end

  # action taken after analyzing log
  def analyze
    @log_text = format(params[:log])
    @log_data = []
    @pattern = ''
    unmatched_text = @log_text.clone

    grok = Grok.new
    grok.add_patterns_from_file("#{Rails.root}/public/patterns/base")

    # format: name, matched_text, start_at_index, regexp
    @log_data = discover(@log_text, grok)
    @log_data.map {|data| unmatched_text.slice!(data[1])}

    new_text = @log_text.clone
    unmatched_text.split(' ').each do |data|
      @log_data << ['<UNKNOWN>', data, new_text.index(data), '']
      replace = "*" * data.length
      new_text.sub!(data, replace)
    end

    # sort by start_at_index
    @log_data.sort_by! {|data| data[2]}
    
    # @pattern = @log_data.map{|item| item[0]}.join(":")
  end # def analyze

  # def suggest_pattern(parsed_pattern)
  #   # ??? SOURCE --> BUDEM POZNAT SOURCE . patterny rozdelene podla sourcu
  #   # FIREWALL .. patterns
  #   # SYSLOG .... patterns
  #   # APP ....... patterns

  #   <IP><UK><UK><TIMESTAMP>

  #   0. <NIECO><USER><TIMESTAMP>
  #   1. <IP><USER><TIMESTAMP>
  #   2. <IP><USER><UID><TIMESTAMP>  # vacsia priorita pretoze kazde UK = nejakej entite

  #   <IP><UK><UK><TIMESTAMP><UK><UK><UK>

  #   1. <IP><USER><TIMESTAMP><MSG>
  #   2. <IP><USER><TIMESTAMP><PID><MSG>

  #   01/20/2016 06:15:05.85 w3wp.exe (0x5154) 03194 SharePoint Foundation Micro Trace Tags: (none) 20fa569d-e927-7055-3239-2cc8d3f9a2b7
  #   TIMESTAMP                PROGRAM   PID     IDD             MSG                                        NUM
  #   TIMESTAMP                PROGRAM   CISLO   CISLO   UK        UK         UK   UK    UK     UK          ...
  #   suggests = []
  #   patterns = Pattern.all

  #   tb_matched = parsed_pattern.split('::')
  #   patterns.each do |pattern|
  #     tokens = pattern.split('::')


  #   end

  # end

  # format entry log of whitespaces
  def format(log)
    return '' unless log
    log.gsub(/\s+/, " ")
  end # def format

  # modified method taken from jls-grok gem for discovering patterns
  def discover(text, grok, unmatched = false)
    tmp_text = text.clone
    suggestions = []

    groks = {}
    grok.patterns.each do |name, expression| 
      tmp_grok = Grok.new
      # Copy in the same grok patterns from the parent
      tmp_grok.patterns.merge!(grok.patterns)
      tmp_grok.compile("%{#{name}}")
      groks[name] = tmp_grok
    end

    patterns = groks.sort { |a, b| compare(a, b) }

    done = false
    while !done
      done = true # will reset this if we are not done later.
      patterns.each do |name, grok|
        # Skip patterns that lack complexity (SPACE, NOTSPACE, DATA, etc)
        
        next if complexity(grok.expanded_pattern) < 20
        m = grok.match(tmp_text)
        # Skip non-matches
        next unless m
        matched_text =  m.captures.values.first.first
        s_position = tmp_text.index(matched_text)
        e_position = s_position + matched_text.length
        
        part = tmp_text[s_position ... e_position]
        # Only include things that have word boundaries (not just words)
        next if part !~ /.\b./
        # Skip over parts that appear to include %{pattern} already
        next if part =~ /%{[^}+]}/
        acting = true

        # save name (ip), text (192.168.0.2), start_at_index (3), pattern (/regex/)
        suggestions << [name, matched_text, text.index(matched_text), grok.expanded_pattern]

        tmp_text[s_position ... e_position] = "%{#{name}}"

        # Start the loop over again
        done = false
        break
      end
    end

    return suggestions
  end # def discover

  def compare(a, b)
    # a and be are each: [ name, grok ]
    # sort highest complexity first
    return complexity(b.last.expanded_pattern) <=> complexity(a.last.expanded_pattern)
  end # def compare

  def complexity(expression)
    score = expression.count("|") # number of branches in the pattern
    score += expression.length # the length of the pattern
  end # def complexity

end
