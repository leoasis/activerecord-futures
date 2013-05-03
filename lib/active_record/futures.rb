module ActiveRecord
  module Futures
    include QueryRecording

    def self.original_calculation_methods
      [:count, :average, :minimum, :maximum, :sum, :calculate]
    end

    def self.future_calculation_methods
      original_calculation_methods.map { |name| "future_#{name}" }
    end

    def future
      FutureRelation.new(self)
    end

    def future_pluck(*args, &block)
      exec = lambda { pluck(*args, &block) }
      query = record_query(&exec)
      FutureCalculationArray.new(self, query, exec)
    end

    method_table = Hash[future_calculation_methods.zip(original_calculation_methods)]

    # define a "future_" method for each calculation method
    #
    method_table.each do |future_method, method|
      define_method(future_method) do |*args, &block|
        exec = lambda { send(method, *args, &block) }
        query = record_query(&exec)
        FutureCalculationValue.new(self, query, exec)
      end
    end
  end
end