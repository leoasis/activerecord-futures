module ActiveRecord
  module Futures
    class Future
      class << self
        # This should be set in a thread scope
        attr_accessor :current

        def all
          # Make this live together with the connection
          # or thread based
          @futures ||= []
        end

        def clear
          all.clear
        end

        def register(future)
          @futures ||= []
          @futures << future
        end

        def flush
          all.each(&:load)
          clear
        end
      end


      attr_reader :result

      def initialize
        Future.register(self)
      end

      def fulfill(result)
        @result = result
      end

      def fulfilled?
        !result.nil?
      end

      def load
        Future.current = self
        execute
        Future.current = nil
      end

      def inspect
        to_a.inspect
      end

      def to_sql
      end
      undef_method :to_sql

    private
      def execute
      end
      undef_method :execute

      def executed?
      end
      undef_method :executed?

    end
  end
end