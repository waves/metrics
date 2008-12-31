require "#{File.dirname(__FILE__)}/helpers"

templates = PathTemplate.generate_random(800)
argses = templates.map { |t| Array.new( t.map { |e| true unless e.is_a? String }.compact.size, "foo") }
zipped = templates.zip(argses)

def generate(zipped, count, offset=50)
  zipped.slice(offset, count).each do |t,a|
    yield t, a.dup
  end 
end

run_count, sample_count = 7, 100

runs = []

run_count.times do
  samples = []
  paths = Class.new( Waves::Resources::Paths ).new
  sample_count.times do
    samples << Benchmark.realtime do
      generate(zipped, 500) { |t,a| paths.generate(t, a)  }
    end
  end
  runs << samples
end

puts "samples median: #{runs.map { |run| run.mean }.median }"
puts "samples mean:  #{runs.map { |run| run.mean }.mean}"
puts "samples stdev:  #{runs.map { |run| run.mean }.standard_deviation}"

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



