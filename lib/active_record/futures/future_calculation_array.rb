module ActiveRecord
  module Futures
    class FutureCalculationArray < FutureCalculation
      include ActiveRecord::Delegation
      delegate :arel, to: :relation

      def initialize(relation, query, binds, execution)
        super
        @klass = relation.klass
      end

      fetch_with(:to_a)
    end
  end
end