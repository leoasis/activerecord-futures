module ActiveRecord
  module Futures
    class FutureCalculationValue < FutureCalculation
      fetch_with(:value)
    end
  end
end