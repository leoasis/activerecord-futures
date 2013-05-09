module ActiveRecord
  module Futures
    class FutureArray
      attr_reader :future_execution
      private :future_execution

      delegate :to_xml, :to_yaml, :length, :collect, :map, :each,
               :all?, :include?, :to_ary, to: :to_a

      def initialize(future_execution)
        @future_execution = future_execution
      end

      def to_a
        future_execution.execute
      end

      def inspect
        to_a
      end
    end
  end
end