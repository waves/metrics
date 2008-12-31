require "#{File.dirname(__FILE__)}/../helpers"
require "#{File.dirname(__FILE__)}/stevedore"
require "foundations/compact"

module PathTemplate
  Strings =  ("a".."z").to_a 
  Symbols = Strings.map {|l| l.to_sym }
  Hashes = []; Symbols.each_with_index { |s, i| Hashes << { s => Strings[i]} }
  SOURCE = Strings + Symbols + Hashes
  
  def self.seed
    @seed ||= 4815162342
  end
  
  def self.seed=(i)
    @seed = i
  end
  
  def self.generate_random(count)
    srand(seed)
    templates = []
    count.times do
      size = rand(4) + 2
      template = []
      size.times { template << SOURCE[rand(SOURCE.size)] }
      templates << template
    end
    templates
  end
end