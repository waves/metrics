require 'rstats'
class Stevedore
  
  attr_accessor :name, :runs
  
  def initialize(name)
    @name = name
    @runs = []
  end
  
  def reset
    @runs = []
  end
  
  def sample_setup
    puts "no setup"
  end
  
  def work(*args)
    raise "you ought to define #{self.class.name}#work"
  end
  
  def sample_teardown
    "stub"
  end
  
  def go(run_count, sample_count, *args)
    
    run_count.times do
      samples = []
      self.sample_setup
      sample_count.times do
        samples << Benchmark.realtime do          
          self.work(*args)
        end
      end
      self.sample_teardown
      @runs << samples
      yield samples if block_given?
    end
    
  end
  
  def means
    @runs.map { |run| run.mean }
  end
  
  def sigmas
    @runs.map { |run| run.standard_deviation }
  end
  
  def runs_mean
    @runs.map { |run| run.mean }.mean
  end
  
  def runs_sigma
    @runs.map { |run| run.mean }.standard_deviation
  end
  
end

Steve = Stevedore