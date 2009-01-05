require "#{File.dirname(__FILE__)}/helpers"

# request = Waves::Request.new( env( "/foo/bar%20baz/bat-hat/doo_dah", :method => 'GET' ) )

Waves::Matchers::Path.module_eval do
  def original_call( request )
    return {} if @pattern == true or @pattern == false or @pattern.nil?
    path = extract_path( request ).reverse
    return {} if ( path.empty? and @pattern.empty? )
    capture = {}
    match =  @pattern.all? do | want |
      case want
      when true # means 1..-1
        path = [] unless path.empty?
      when Range 
        if want.end == -1
          path = [] if path.length >= want.begin
        else
          path = [] if want.include? path.length
        end
      when String then want == path.pop
      when Symbol then capture[ want ] = path.pop
      when Regexp then want === path.pop
      when Hash
        key, value = want.to_a.first
        case value
        when true
          ( capture[ key ], path = path.reverse, [] ) unless path.empty?
        when Range
          if value.end == -1
            ( capture[ key ], path = path.reverse, [] ) if path.length >= value.begin
          else
            ( capture[ key ], path = path.reverse, [] ) if value.include? path.length
          end
        when String, Symbol
          got = path.pop
          capture[ key ] = got ? got : value.to_s
        when Regexp then
          got = path.pop
          capture[ key ] = got if value === got
        end
      end
    end
    capture if match && path.empty?
  end
end

def request(path)
  Waves::Request.new( env( path, :method => 'GET' ) )
end


class PathMatch < Steve
  include PathTemplate
  
  power 0.7
  sig_level 0.1
  before do
    @templates = generate_random(500)
    @request =  request("/foo/bar%20baz/bat-hat/doo_dah")
    @matchers = @templates.map { |t| Waves::Matchers::Path.new( t ) } 
  end
end

n = 1000

mine = PathMatch.new "Me" do
  measure do
    @matchers.each do |matcher|
      matcher.call(@request)
    end
  end
end

original = PathMatch.new "Dan" do
  measure do
    @matchers.each do |matcher|
      matcher.call(request)
    end
  end
end

PathMatch.compare_instances( 4, 32 )