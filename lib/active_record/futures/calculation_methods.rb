module ActiveRecord
  module Futures
    module CalculationMethods
      extend ActiveSupport::Concern

      def future_pluck(*args, &block)
        exec = lambda { pluck(*args, &block) }
        query, binds = record_query(&exec)
        FutureCalculationArray.new(self, query, binds, exec)
      end

      included do
        methods = original_calculation_methods - [:pluck]

        # define a "future_" method for each calculation method
        #
        methods.each do |method|
          define_method(futurize(method)) do |*args, &block|
            exec = lambda { send(method, *args, &block) }
            query, binds = record_query(&exec)
            FutureCalculationValue.new(self, query, binds, exec)
          end
        end
      end

      module ClassMethods

        def original_calculation_methods
          [:count, :average, :minimum, :maximum, :sum, :calculate, :pluck]
        end

        def future_calculation_methods
          original_calculation_methods.map { |method| futurize(method) }
        end
      end
    end
  end
end