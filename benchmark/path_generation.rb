require "#{File.dirname(__FILE__)}/helpers"

class PathGenPerf < Steve
  include PathTemplateGenerator
  
  before do
    # set up the Paths object
    @paths = Class.new( Waves::Resources::Paths ).new
  end

  before_measure do
    # generate an array of [template, args] before each measurement
    @templates_and_args = templates_and_args(400)
  end
  
end

precompiled = PathGenPerf.new("New method, test paths precompiled") do
  before_sample do
    # precompile the templates that will be used
    @precompile = templates_and_args(400)
    @precompile.each { |t,a| @paths.generate(t, a)  }
  end
  measure do
    @templates_and_args.each { |t,a| @paths.generate(t, a)  }
  end
end

compiled = PathGenPerf.new("New method, no precompilation") do
  measure do
    @templates_and_args.each { |t,a| @paths.generate(t, a)  }
  end
  after_measure do
    @paths.compiled_paths.clear
  end
end

original = PathGenPerf.new("Old method") do
  measure do
    @templates_and_args.each { |t,a| @paths.original_generate(t, a)  }
  end
end

PathGenPerf.recommend_test_size(10, 50)

# precompiled.preliminary(10, 60)
# 
# compiled.preliminary(10, 60)
# 
# original.preliminary(10, 60)

# precompiled.go(3, 50)
# precompiled.report
# 
# compiled.go(3, 50)
# compiled.report
# 
# original.go(3, 50)
# original.report