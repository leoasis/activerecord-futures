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
      supports_futures = connection.respond_to?(:supports_futures?) &&
                         connection.supports_futures?

      # simply pass through if the connection adapter does not support
      # futures
      supports_futures ? FutureRelation.new(self) : self
    end

    def future_pluck(column_name)
      exec = lambda { pluck(column_name) }
      query = record_query(&exec)
      FuturePluck.new(query, exec)
    end

    method_table = Hash[future_calculation_methods.zip(original_calculation_methods)]

    # define a "future_" method for each calculation method
    #
    method_table.each do |future_method, method|
      define_method(future_method) do |*args, &block|
        exec = lambda { send(method, *args, &block) }
        query = record_query(&exec)
        FutureCalculation.new(query, exec)
      end
    end
  end
end