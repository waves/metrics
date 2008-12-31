require "#{File.dirname(__FILE__)}/helpers"

templates = PathTemplate.generate_random(800)
argses = templates.map { |t| Array.new( t.map { |e| true unless e.is_a? String }.compact.size, "foo") }
zipped = templates.zip(argses)

class PathGenPerf < Steve
  
  sample_setup do
    @paths = Class.new( Waves::Resources::Paths ).new
  end
  
  # helper methods
  def foo(zipped, count, offset=50)
    zipped.slice(offset, count).each do |t,a|
      yield t, a.dup
    end 
  end
end

compiled = PathGenPerf.new("Path generation with compilation")
compiled.work do
  foo(zipped, 100) { |t,a| @paths.generate(t, a)  }
end

compiled.go(3, 250, zipped)
compiled.report

# precompiled = PathGenPerf.new("Path generation with precompiled paths")
# 
# def precompiled.sample_setup(zipped)
#   @paths = Class.new( Waves::Resources::Paths ).new
#   generate(zipped, 500) { |t,a| @paths.generate(t, a)  }
# end
# 
# def precompiled.work(zipped)
#   generate(zipped, 100) { |t,a| @paths.generate(t, a)  }
# end
# 
# precompiled.go(3, 250, zipped)
# precompiled.report
# 
# original = PathGenPerf.new("Path generation (original method)")
# 
# def original.work(zipped)
#   generate(zipped, 100) { |t,a| @paths.original_generate(t, a)  }
# end
# 
# original.go(3, 250, zipped)
# original.report

# puts "Path generation benchmarks"
# 
# Benchmark.bmbm(20) do |x|
#   
#   paths = Class.new( Waves::Resources::Paths ).new
#   
#   x.report("compiled:    50 paths") do
#     iterations.times do
#       generate(zipped, 50) { |t,a| paths.generate(t, a)  }
#     end
#   end
#     
#   paths = Class.new( Waves::Resources::Paths ).new
#   generate(zipped, 50) { |t,a| paths.generate(t, a)  }
#   
#   x.report("precompiled: 50/#{paths.compiled_paths.size} paths") do
#     iterations.times do
#       generate(zipped, 50) { |t,a| paths.generate(t, a)  }
#     end
#   end
#   
#   paths = Class.new( Waves::Resources::Paths ).new
#   generate(zipped, 100) { |t,a| paths.generate(t, a)  }
#   
#   x.report("precompiled: 50/#{paths.compiled_paths.size} paths") do
#     iterations.times do
#       generate(zipped, 50) { |t,a| paths.generate(t, a)  }
#     end
#   end
#   
#   paths = Class.new( Waves::Resources::Paths ).new
#   generate(zipped, 501) { |t,a| paths.generate(t, a)  }
#   
#   x.report("precompiled: 50/#{paths.compiled_paths.size} paths") do
#     iterations.times do
#       generate(zipped, 50) { |t,a| paths.generate(t, a)  }
#     end
#   end
#   
#   paths = Class.new( Waves::Resources::Paths ).new
#   
#   x.report("*original*:  50 paths") do
#     iterations.times do
#       generate(zipped, 50) { |t,a| paths.original_generate(t, a)  }
#     end
#   end
#   
#   
# end



