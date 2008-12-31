require 'rsruby'
require 'benchmark'
class Stevedore
  
  def self.instances; @instances ||= []; end
  
  def self.reset; @instances = []; end
  
  def self.sample_setup(&block)
    block ? @sample_setup = block : @sample_setup
  end  
  
  def self.sample_teardown(&block)
    block ? @sample_teardown = block : @sample_teardown
  end
  
  def self.run_setup(&block)
    block ? @run_setup = block : @run_setup
  end
  
  def self.run_teardown(&block)
    block ? @run_teardown = block : @run_teardown
  end
  
  attr_accessor :name, :runs, :delta, :sig_level, :power, :r
  
  def initialize(name)
    klass = self.class
    klass.instances << self
    @sample_setup, @sample_teardown = klass.sample_setup, klass.sample_teardown
    @run_setup, @run_teardown = klass.run_setup, klass.run_teardown
    @name = name
    @runs = []
    @r = RSRuby.instance
    @delta = 0.001
    @power = 0.9
    @sig_level = 0.01
  end
  
  def reset
    @runs = []
  end
  

  
  
  def sample_setup(&block); @sample_setup = block; end
  def sample_teardown(&block); @sample_teardown = block; end
  def run_setup(&block); @run_setup = block; end
  def run_teardown(&block); @run_teardown = block; end
  
  def work(&block); @work = block; end
  
  
  def go(run_count, sample_count, *args)
    
    run_count.times do
      samples = []
      sample_count.times do
        instance_eval &@sample_setup if @sample_setup
        samples << Benchmark.realtime do          
          instance_eval &@work
        end
        instance_eval &@sample_teardown if @sample_teardown
      end
      @runs << samples
      yield samples if block_given?
    end
    
  end
  
  # statistics
  
  def sample_means
    @runs.map { |samples| @r.mean(samples) }
  end
  
  def sample_standard_deviations
    @runs.map { |samples| @r.sd(samples) }
  end
  
  def mean
    @r.mean(@runs.flatten)
  end
  
  def standard_deviation
    @r.sd(@runs.flatten)
  end
  
  def power_test(sd)
    { :delta => @delta, :power => @power, :sig_level => @sig_level, :sd => sd }
    @r.power_t_test 
  end
  
  def report
    puts self.name
    puts "Mean: #{self.mean}"
    puts "Overall standard deviation: #{self.standard_deviation}"
    puts "Max sample standard deviation: #{@r.max self.sample_standard_deviations}"
    puts "Sample means standard_deviation: #{self.sample_means.standard_deviation}"
    puts
  end
  
  
end

Steve = Stevedore