module ActiveRecord
  module Futures
    class FutureCalculationValue < FutureCalculation
      fetch_with(:value) { @value }
    end
  end
end