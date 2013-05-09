module ActiveRecord
  module Futures
    module CalculationMethods
      extend ActiveSupport::Concern

      def future_pluck(*args, &block)
        FutureArray.new(record_future(:pluck, *args, &block))
      end

      included do
        methods = original_calculation_methods - [:pluck]

        # define a "future_" method for each calculation method
        #
        methods.each do |method|
          define_method(futurize(method)) do |*args, &block|
            FutureValue.new(record_future(method, *args, &block))
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