class PathGen
  
  Strings =  ("a".."z").to_a 
  Symbols = Strings.map {|l| l.to_sym }
  Regexes = Array.new( 26, /smurf/ )
  
  def seed; @seed ||= 4815162342; end
  def seed=(i); @seed = i; end
  
  attr_accessor :sources, :max, :min
    
  def initialize(options={})
    options = { :length => 2..5 }.merge(options)
    weighting(options)
    @min, @max = options[:length].first, options[:length].last
  end
  
  def inspect
    "#<#{self.class.name} @min=#{@min}, @max=#{@max}, @weighting=#{@weights.inspect}>"
  end
  
  def length=(range)
    @min, @max = range.first, range.last
  end
  
  def weighting(weights={})
    @weights = { :strings => 1, :symbols => 1}.merge(weights)
    @sources = []
    @value_sources = []
    @value_sources.concat Strings * @weights[:strings].to_i
    @value_sources.concat Symbols *  @weights[:symbols].to_i
    @value_sources.concat Regexes * @weights[:regexes].to_i
    
    hashes = []; weights[:hashes].to_i.times do
       Symbols.each do |s|
        hashes << { s => @value_sources[rand(@value_sources.size)] }
      end
    end
    @sources.concat @value_sources + hashes
  end
  
  def templates(count)
    srand(seed)
    templates = []
    count.times do
      size = rand(@max - @min) + @min
      template = []
      size.times { template << @sources[rand(@sources.size)] }
      templates << template
    end
    @templates = templates
  end
  
  def args
    @templates.map do |template|
      args_for(template)
    end
  end
  
  def args_for(template)
    size = template.reject { |e| e.is_a? String }.size
    Array.new size, "smurf"
  end
  
  def paths
    @templates.map do |template|
      path_for(template)
    end
  end
  
  def path_for(template)
    "/" << template.map do |element|
      case element
      when String then element
      when Symbol then "#{element}_value"
      when Regexp then "smurf" # all regexes are /smurf/
      when Hash
        key, value = element.to_a.first
        out = case value
        when String, Symbol then "#{key}_value"
        when Regexp then "smurf" # all regexes are /smurf/
        end
      end
    end.join("/")
  end

  def templates_and_args(count)
    t = templates(count)
    a = args
    t.zip a
  end
  
end
