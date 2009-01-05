require "#{File.dirname(__FILE__)}/helpers"

class PathGeneration < Steve
  include PathTemplate
  
  power 0.8
  sig_level 0.05
  delta 0.001
  
  before do
    @paths = Class.new( Waves::Resources::Paths ).new
  end

  before_measure do
    # generate an array of [template, args] before each measurement
    @templates_and_args = templates_and_args(200)
  end
  
end


precompiled = PathGeneration.new("New method, test paths precompiled") do
  before_sample do
    @precompile = templates_and_args(200)
    @precompile.each { |t,a| @paths.generate(t, a)  }
  end
  measure do
    @templates_and_args.each { |t,a| @paths.generate(t, a)  }
  end
end

# compiled = PathGeneration.new("New method, no precompilation") do
#   measure do
#     @templates_and_args.each { |t,a| @paths.generate(t, a)  }
#   end
#   after_measure do
#     @paths.compiled_paths.clear
#   end
# end

original = PathGeneration.new("Old method") do
  measure do
    @templates_and_args.each { |t,a| @paths.original_generate(t, a)  }
  end
end


# test_size = PathGeneration.recommend_test_size(8, 64)

PathGeneration.compare_instances(8, 32)

