module ActiveRecord
  module Futures
    class FutureCalculationArray < FutureCalculation
      include ActiveRecord::Delegation
      fetch_with(:to_a) { @value }
    end
  end
end