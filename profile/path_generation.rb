require "#{File.dirname(__FILE__)}/../helpers"
require 'ruby-prof'

paths = Class.new( Waves::Resources::Paths ).new

result = RubyProf.profile do

  100.times { paths.generate( ['some', :template], ["arg"]) }
  
end

printer = RubyProf::GraphPrinter.new(result)
printer.print(STDOUT, 5)