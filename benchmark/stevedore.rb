require 'rsruby'
require 'benchmark'

class Stevedore
  
  def self.instances; @instances ||= []; end
  
  def self.reset; @instances = []; end
  
  def self.power_test(r, sd)
    if sd < 0.00007
      warn "Stddev is very small, which makes power.t.test sad. Setting stddev to 0.00007 so we can get this done."
      sd = 0.00007
    end
    r.power_t_test :delta => 0.001, :power => 0.9, :sig_level => 0.01, :sd => sd 
  end
  
  def self.recommend_test_size(run_count, sample_size)
    @instances.each do |instance|
      puts "Running '#{instance.name}'"
      instance.go(run_count, sample_size)
      puts "Mean:   #{instance.mean}"
      puts "Stddev: #{instance.standard_deviation}"
    end
    worst = @instances.sort_by { |i| i.standard_deviation }.last
    puts "\nUsing '#{worst.name}' for power test, because it has the greatest stddev."
    r = RSRuby.instance
    rec_runs = power_test(r, worst.standard_deviation )['n'].to_i
    rec_size = power_test(r, r.sd( worst.sample_means) )['n'].to_i
    puts "Power test recommends #{rec_runs} sample runs of #{rec_size} measurements."
    [rec_runs, rec_size]
  end
  
  def self.before(&block)
    block ? @before = block : @before
  end
  
  def self.after(&block)
    block ? @after = block : @after
  end
  
  def self.before_sample(&block)
    block ? @before_sample = block : @before_sample
  end
  
  def self.after_sample(&block)
    block ? @after_sample = block : @after_sample
  end
  
  def self.before_measure(&block)
    block ? @before_measure = block : @before_measure
  end  
  
  def self.after_measure(&block)
    block ? @after_measure = block : @after_measure
  end
  
  
  
  attr_accessor :name, :samples, :delta, :sig_level, :power, :r
  
  def initialize(name, &block)
    klass = self.class
    klass.instances << self
    @before, @after = klass.before, klass.after
    @before_measure, @after_measure = klass.before_measure, klass.after_measure
    @before_sample, @after_sample = klass.before_sample, klass.after_sample
    @name = name
    @samples = []
    @r = RSRuby.instance
    @delta = 0.001
    @power = 0.9
    @sig_level = 0.01
    instance_eval( &block ) if block
  end
  
  def reset
    @samples = []
  end
  
  # Run a small set of samples and use a power test to determine
  # the optimal run count and sample size.
  def preliminary(run_count, sample_size)
    go(run_count, sample_size)
    pt = power_test( @r.sd( self.sample_means ) )
    puts "Power test recommends at least #{pt["n"].to_i} samples" if pt
    pt = power_test( @r.max( self.sample_standard_deviations ) )
    puts "Power test recommends at least #{pt["n"].to_i} measurements\n\n" if pt
  end
  
  def go(run_count, sample_size)
    reset
    instance_eval( &@before ) if @before
    run_count.times do
      sample = []
      instance_eval( &@before_sample ) if @before_sample
      sample_size.times do
        instance_eval( &@before_measure ) if @before_measure
        sample << Benchmark.realtime do          
          instance_eval( &@measure )
        end
        instance_eval( &@after_measure ) if @after_measure
      end
      instance_eval( &@after_sample ) if @after_sample
      @samples << sample
    end
    instance_eval( &@after ) if @after
  end
  
  # Define a block to evaluate before any samples are taken
  def before(&block); @before = block; end
  
  # Define a block to evaluate after all samples have been taken
  def after(&block); @after = block; end
  
  # Define a block to evaluate before each sample run
  def before_sample(&block); @before_sample = block; end
  
  # Define a block to evaluate after each sample run
  def after_sample(&block); @after_sample = block; end
  
  # Define a block to evaluate before each measurement
  def before_measure(&block); @before_measure = block; end
  
  # Define a block to evaluate after each measurement
  def after_measure(&block); @after_measure = block; end
  
  def measure(&block); @measure = block; end
  
  

  
  # statistics
  
  def sample_means
    @samples.map { |s| @r.mean(s) }
  end
  
  def sample_standard_deviations
    @samples.map { |s| @r.sd(s) }
  end
  
  def mean
    @r.mean(@samples.flatten)
  end
  
  def standard_deviation
    @r.sd(@samples.flatten)
  end
  
  def power_test(sd)
    @r.power_t_test :delta => @delta, :power => @power, :sig_level => @sig_level, :sd => sd 
  rescue RException
    puts "R power.t.test puked, probably because of a very low standard deviation."
  end
  
  def report
    puts self.name
    puts "#{run_count} sample runs, #{sample_size} measurements each"
    puts "  Mean: #{self.mean}"
    puts "  Overall standard deviation: #{self.standard_deviation}"
    # puts "Max sample standard deviation: #{@r.max self.sample_standard_deviations}"
    puts "  Sample means standard_deviation: #{@r.sd self.sample_means}"
    puts
  end
  
  
end

Steve = Stevedore