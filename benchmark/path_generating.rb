require "#{File.dirname(__FILE__)}/helpers"


class PathGenerating < Steve
  # include PathTemplate
  
  power 0.8
  sig_level 0.05
  delta 0.001
  
  before do
    @paths = Class.new( Waves::Resources::Paths ).new
    @generator = PathGen.new :length => 2..5, :strings => 3, :symbols => 1, :hashes => 1
  end

  before_measure do
    # generate array of [template, args] before each measurement
    # because the path generation code consumes args
    @templates_and_args = @generator.templates_and_args(500)
  end
  
end


precompiled = PathGenerating.new("New method, precompiled paths") do
  before_sample do
    @precompile = @generator.templates_and_args(500)
    @precompile.each { |t,a| @paths.generate(t, a)  }
  end
  measure do
    @templates_and_args.each { |t,a| @paths.generate(t, a)  }
  end
end

original = PathGenerating.new("Old method") do
  measure do
    @templates_and_args.each { |t,a| @paths.original_generate(t, a)  }
  end
end

# test_size = PathGenerating.recommend_test_size(8, 64)

PathGenerating.compare_instances(4, 32)

