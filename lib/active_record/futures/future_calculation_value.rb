module ActiveRecord
  module Futures
    class FutureCalculationValue < FutureCalculation
      fetch_with(:value)

      def inspect
        value.inspect
      end
    end
  end
end