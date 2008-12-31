require 'rubygems'; %w{ rstats }.each { |dep| require dep }

$:.unshift("#{File.dirname(__FILE__)}/../lib")
require 'waves'
require 'runtime/mocks'
include Waves::Mocks

