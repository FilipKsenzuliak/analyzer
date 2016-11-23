class AnalyzerController < ApplicationController
  # requiring here since gem is called jls-grok and this also needs to be included
  require 'grok-pure'
  require 'pp'

  # example log: 01/20/2016 06:15:05.85 w3wp.exe (0x5154) 03194 SharePoint Foundation Micro Trace uls4 Medium Micro Trace Tags: (none) 20fa569d-e927-7055-3239-2cc8d3f9a2b7 
  # UPRAVIT GROUP ELEMENTS
  # PRIDAT MOZNO EXPORT PATTERNOV
  # FORM_PARSER -> redirect_to analyzer/discover -> respond to js a zmenit matched data
  ##### DEFINOVANY PATTERN ALE NIE JEHO CAST %{USERPID}
  def index
    @hide = ''
  end

  def analyze
    @pattern = Pattern.new
    @log_text = format(params[:log])
    @include = params[:include]
    log_separator = params[:separator]
    #@hide = 'hide'
    @log_data = []
    unmatched_text = @log_text.clone
    session[:log] = @log_text

    redirect_to '/start', notice: 'Enter the log to be analyzed' if @log_text == '' 

    @grok = Grok.new
    parsers = Parser.all
    parsers.each do |p|
      @grok.add_pattern(p.name, p.expression)
    end

    if @include
      Pattern.all.each_with_index do |p, i|
        @grok.add_pattern('KNOWN_PATTERN' + i.to_s, p.text)
      end
    end

    new_text = @log_text.clone
    @log_data = discover(@log_text, @grok)

    # remove matched data from text
    @log_data.map do |data|
      text = data[:match][:matched_text].first
      replace = "*" * text.length
      new_text.sub!(text, replace)
      unmatched_text.sub!(text, ' ')
    end
    
    # mark unknown data
    log_separator = ' ' if log_separator == '(space)'
    unmatched_text.split(log_separator).each do |d|
      format(d).split(' ').each do |data|
        @log_data << {
                      match: {name: '<UNKNOWN>', matched_text: [data], sub: []},
                      start_at: new_text.index(data),
                      pattern: ''
                     }
        replace = "*" * data.length
        new_text.sub!(data, replace)
      end
    end

    # add log to samples if it matches
    @pattern = Pattern.new
    if @log_data.size == 1 && @include
      @pattern = Pattern.where(["text = ?", @log_data.first[:pattern]]).first
      pp @pattern
      if @pattern.logs.size <= 4
        log = Log.new(text: @log_data.first[:match][:matched_text].first , pattern_id: @pattern.id)
        log.save
      end
    end

    @log_data.sort_by! {|data| data[:start_at]}
    result = suggest_pattern(@log_data.map{|item| '%{' + item[:match][:name].to_s + '}'}.join(" "))
    values = result.sort_by{|k, v| v}.first 3

    @suggestions = []
    values.each do |k, v|
      @suggestions << k
    end

  end # def analyze

  # aproximate pattern matching
  def suggest_pattern(parsed_pattern)
    suggestions = {}
    Pattern.all.each do |pattern|
      cmp_min = Levenshtein.normalized_distance pattern.text.to_s, parsed_pattern.to_s
      suggestions[pattern.text.to_s] = cmp_min
    end
    suggestions
  end # def suggest_pattern

  # return max n elements from array
  def max_n(n, &block)
    block = Proc.new { |x,y| x <=> y } if block == nil
    stable = SortedArray.new(&block) 
    each do |x|
      stable << x if stable.size < n or block.call(x, stable[0]) == 1
      stable.shift until stable.size <= n
    end
    return stable 
  end # def max_n

  # format entry log of whitespaces
  def format(log)
    return '' unless log
    # remove whitespaces, single and double quotes
    log.gsub(/\s+/, " ").gsub(/['"]/, '')
  end # def format

  # modified method taken from jls-grok gem for discovering patterns
  def discover(text, grok, unmatched = false)
    tmp_text = text.clone
    parsed_data = []

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
        
        # Only include things that have word boundaries (not just words)
        next if matched_text !~ /.\b./
        # Skip over parts that appear to include %{pattern} already
        next if matched_text =~ /%{[^}+]}/
        acting = true

        match = expand_pattern(grok.pattern, grok, m.captures, 5)
        parsed_data << {
                        match: match,
                        start_at: tmp_text.index(matched_text),
                        pattern: grok.patterns[name]#grok.expanded_pattern
                       }
        replace = "*" * matched_text.length
        tmp_text.sub!(matched_text, replace)

        # Start the loop over again
        done = false
        break
      end
    end

    return parsed_data
  end # def discover

  def compare(a, b)
    # a and be are each: [ name, grok ]
    # sort highest complexity first
    return complexity(b.last.expanded_pattern) <=> complexity(a.last.expanded_pattern)
  end # def compare

  def complexity(expression)
    score = expression.count("|") # number of branches in the pattern
    score += expression.length # the length of the pattern
  end # def 

  # returns hash of expanded pattern names and values
  # limit - maximum number of recursive iterations
  def expand_pattern(pattern, grok, captures, limit)
    pattern.gsub!(/[{}%]/,'')
    match_data = {}

    if grok.patterns.include?(pattern) && limit >= 0
      regex = grok.patterns[pattern]
      # match all sub-patterns
      matches = regex.scan(/%{\w+}/)

      matched_text = captures[pattern]
      data = []
      matches.each do |item|
        data << expand_pattern(item, grok, captures, limit-1)
      end

      match_data = {
                    name: pattern,
                    matched_text: matched_text,
                    pattern: grok.patterns[pattern],
                    sub: data
                   }

      return match_data
    else
      return nil
    end
  end # def expand_pattern
end
