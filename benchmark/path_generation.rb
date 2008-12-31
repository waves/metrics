require "#{File.dirname(__FILE__)}/helpers"

class PathGenPerf < Steve
  
  module Data
    
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
        size = rand(4) + 2
        template = []
        size.times { template << SOURCE[rand(SOURCE.size)] }
        templates << template
      end
      templates
    end

    def templates_and_args(count)
      templates = generate_random_templates(800)
      argses = templates.map { |t| Array.new( t.map { |e| true unless e.is_a? String }.compact.size, "foo") }
      zipped = templates.zip(argses)
      zipped.slice(0, count).map { |t,a| [t, a.dup] }
    end
    
    module_function :generate_random_templates, :seed, :seed=, :templates_and_args
  end
  
  include Data
end

PathGenPerf.before do
  # set up the Paths object
  @paths = Class.new( Waves::Resources::Paths ).new
end

PathGenPerf.before_measure do
  # generate an array of [template, args] before each measurement
  @templates_and_args = templates_and_args(100)
end

precompiled = PathGenPerf.new("New method, test paths precompiled")
precompiled.before_sample do
  # precompile the templates that will be used
  @precompile = templates_and_args(100)
  @precompile.each { |t,a| @paths.generate(t, a)  }
end
precompiled.measure do
  @templates_and_args.each { |t,a| @paths.generate(t, a)  }
end

compiled = PathGenPerf.new("New method, no precompilation")
compiled.measure do
  @templates_and_args.each { |t,a| @paths.generate(t, a)  }
end
compiled.after_measure do
  @paths.compiled_paths.clear
end


original = PathGenPerf.new("Old method")
original.measure do
  @templates_and_args.each { |t,a| @paths.original_generate(t, a)  }
end

precompiled.go(5, 50)
precompiled.report

compiled.go(5, 50)
compiled.report

original.go(5, 50)
original.report