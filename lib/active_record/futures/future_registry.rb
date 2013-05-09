module ActiveRecord
  module Futures
    module FutureRegistry
      def futures
        Thread.current["#{self.name}_futures"] ||= []
      end
      alias_method :all, :futures

      def current
        Thread.current["#{self.name}_current"]
      end

      def current=(future)
        Thread.current["#{self.name}_current"] = future
      end

      def clear
        all.clear
      end

      def register(future)
        self.futures << future
      end

      def flush
        self.futures.each(&:load)
        clear
      end

      extend self
    end
  end
end