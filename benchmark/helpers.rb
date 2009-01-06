require "#{File.dirname(__FILE__)}/../helpers"
require "foundations/compact"

$:.unshift "#{File.dirname(__FILE__)}/stevedore/lib"
require 'stevedore'

module PathTemplate
  
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
  
  
  
  def generate_random(count)
    srand(seed)
    templates = []
    count.times do
      size = rand(5) + 2
      template = []
      size.times { template << SOURCE[rand(SOURCE.size)] }
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



