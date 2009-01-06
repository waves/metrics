require "#{File.dirname(__FILE__)}/../helpers"
require "foundations/compact"

$:.unshift "#{File.dirname(__FILE__)}/stevedore/lib"
require 'stevedore'

class PathTemplateGenerator
  
  Strings =  ("a".."z").to_a 
  Symbols = Strings.map {|l| l.to_sym }
  Regexes = []; 26.times { Regexes << /smurf/ }
  Values = Strings + Symbols + Regexes
  Hashes = []; Symbols.each_with_index do |s, i|
    Hashes << { s => Values[rand(Values.size)]}
  end
  SOURCE = Strings + Symbols + Regexes + Hashes
  
  def seed; @seed ||= 4815162342; end
  def seed=(i); @seed = i; end
  
  attr_accessor :sources
    
  def initialize(weights=nil)
    weights ? weighting(weights) : weighting( :strings => 1, :symbols => 1, :regexes => 1, :hashes => 1)
  end
  
  def weighting(weights={})
    @sources = []
    @value_sources = []
    string_weight = weights[:strings] || 1
    symbol_weight = weights[:symbols] || 1 
    @value_sources.concat Strings * string_weight.to_i
    @value_sources.concat Symbols *  symbol_weight.to_i
    @value_sources.concat Regexes * weights[:regexes].to_i
    
    hashes = []; weights[:hashes].to_i.times do
       Symbols.each do |s|
        hashes << { s => @value_sources[rand(@value_sources.size)] }
      end
    end
    @sources.concat (@value_sources + hashes)
  end
  
  def hashes
    
  end
  
  def random(count)
    srand(seed)
    templates = []
    count.times do
      size = rand(5) + 2
      template = []
      size.times { template << @sources[rand(@sources.size)] }
      templates << template
    end
    templates
  end
  
  def args_for_template(template)
    Array.new(template.map { |e| true unless e.is_a? String }.compact.size, "smurf" )
  end
  
  def path_for_template(template)
    template.map do |element|
      case element
      when String
        element
      when Symbol
        "#{element}_value"
      when Regexp # all regexes are /smurf/
        "smurf"
      when Hash
        key, value = element.to_a.first
        out = case value
        when String, Symbol
          "#{key}_value"
        when Regexp
          "smurf" # all regexes are /smurf/
        end
      end
    end
  end

  def templates_and_args(count)
    @templates ||= generate_random(count)
    argses = @templates.map { |t| args_for_template(t) }
    zipped = @templates.zip(argses)
    zipped.slice(0, count).map { |t,a| [t, a.dup] }
  end
  
end



