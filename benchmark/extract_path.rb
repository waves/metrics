require "#{File.dirname(__FILE__)}/helpers"



Waves::Matchers::Path.module_eval do
  def original_extract_path( request )
    path = request.traits.waves.path
    return path if path
    path = request.path.split('/').map { |e| Rack::Utils.unescape(e) }
    path.shift unless path.empty?
    request.traits.waves.path = path
  end
end


matcher = Waves::Matchers::Path.new( [ "" ] )

class ExtractPath < Steve
  power 0.7
  sig_level 0.1
  before do
    @request = Waves::Request.new( env( "/foo/bar%20baz/bat-hat/doo_dah", :method => 'GET' ) )
    @matcher = Waves::Matchers::Path.new( [ "" ] ) 
  end
end

n = 1000

using_split = ExtractPath.new "Using String#split" do
  measure do
    n.times { @matcher.original_extract_path(@request)}
  end
end

using_scan = ExtractPath.new "Using String#scan" do
  measure do
    n.times { @matcher.extract_path(@request) }
  end
end


# ExtractPath.recommend_test_size( 4, 32) 

ExtractPath.compare_instances( 2, 20 ) # =>
# Delta of 0.001 is significant
# Name                       Mean       Stddev      Minimum       Median          Max
# -----------------------------------------------------------------------------------
# Using String#split     0.033922     0.004809     0.032646     0.032892     0.061632
# Using String#scan      0.031665     0.004802     0.030399     0.030635     0.058431

