require 'rubygems'; %w{  }.each { |dep| require dep }

$:.unshift("#{File.dirname(__FILE__)}/../lib")
require 'waves'
require 'runtime/mocks'
include Waves::Mocks

