require "#{File.dirname(__FILE__)}/../helpers"
require "#{File.dirname(__FILE__)}/stevedore"
require "foundations/compact"

module PathTemplateGenerator
  
  Strings =  ("a".."z").to_a 
  Symbols = Strings.map {|l| l.to_sym }
  Hashes = []; Symbols.each_with_index { |s, i| Hashes << { s => Strings[i]} }
  SOURCE = Strings + Symbols + Hashes
  
  def seed; @seed ||= 4815162342; end
  def seed=(i); @seed = i; end
  
  def generate_random_templates(count)
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

  def templates_and_args(count)
    @templates ||= generate_random_templates(count)
    argses = @templates.map { |t| Array.new( t.map { |e| true unless e.is_a? String }.compact.size, "foo") }
    zipped = @templates.zip(argses)
    zipped.slice(0, count).map { |t,a| [t, a.dup] }
  end
  
  module_function :generate_random_templates, :seed, :seed=, :templates_and_args
end