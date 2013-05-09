module ActiveRecord
  module Futures

    def self.futurize(method)
      "future_#{method}"
    end

    include QueryRecording
    include FinderMethods
    include CalculationMethods

    def future
      FutureArray.new(record_future(:to_a))
    end

  private
    def record_future(method, *args, &block)
      exec = -> { send(method, *args, &block) }
      query, binds = record_query(&exec)
      Future.new(self, query, binds, exec)
    end
  end
end