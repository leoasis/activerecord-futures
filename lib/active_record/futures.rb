module ActiveRecord
  module Futures

    def self.futurize(method)
      "future_#{method}"
    end

    include QueryRecording
    include FinderMethods
    include CalculationMethods

    def future
      FutureRelation.new(self)
    end
  end
end