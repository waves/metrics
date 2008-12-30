require "#{File.dirname(__FILE__)}/helpers"

templates = PathTemplate.generate_random(800)
argses = templates.map { |t| Array.new( t.map { |e| true unless e.is_a? String }.compact.size, "foo") }
zipped = templates.zip(argses)

def generate(zipped, count, offset=50)
  zipped.slice(offset, count).each do |t,a|
    yield t, a.dup
  end 
end

n = 5000

puts "Path generation benchmarks"

Benchmark.bmbm(20) do |x|
  
  paths = Class.new( Waves::Resources::Paths ).new
  
  x.report("compiled:    50 paths") do
    n.times do
      generate(zipped, 50) { |t,a| paths.generate(t, a)  }
    end
  end
    
  paths = Class.new( Waves::Resources::Paths ).new
  generate(zipped, 50) { |t,a| paths.generate(t, a)  }
  
  x.report("precompiled: 50/#{paths.compiled_paths.size} paths") do
    n.times do
      generate(zipped, 50) { |t,a| paths.generate(t, a)  }
    end
  end
  
  paths = Class.new( Waves::Resources::Paths ).new
  generate(zipped, 100) { |t,a| paths.generate(t, a)  }
  
  x.report("precompiled: 50/#{paths.compiled_paths.size} paths") do
    n.times do
      generate(zipped, 50) { |t,a| paths.generate(t, a)  }
    end
  end
  
  paths = Class.new( Waves::Resources::Paths ).new
  generate(zipped, 501) { |t,a| paths.generate(t, a)  }
  
  x.report("precompiled: 50/#{paths.compiled_paths.size} paths") do
    n.times do
      generate(zipped, 50) { |t,a| paths.generate(t, a)  }
    end
  end
  
  paths = Class.new( Waves::Resources::Paths ).new
  
  x.report("*original*:  50 paths") do
    n.times do
      generate(zipped, 50) { |t,a| paths.original_generate(t, a)  }
    end
  end
  
  
end



