require "#{File.dirname(__FILE__)}/../helpers"
require "foundations/compact"

$:.unshift "#{File.dirname(__FILE__)}/stevedore/lib"
require 'stevedore'

module PathTemplate
  
  Strings =  ("a".."z").to_a 
  Symbols = Strings.map {|l| l.to_sym }
  Hashes = []; Symbols.each_with_index { |s, i| Hashes << { s => Strings[i]} }
  SOURCE = Strings + Symbols + Hashes
  
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

  def templates_and_args(count)
    @templates ||= generate_random(count)
    argses = @templates.map { |t| args_for_template(t) }
    zipped = @templates.zip(argses)
    zipped.slice(0, count).map { |t,a| [t, a.dup] }
  end
  
end



