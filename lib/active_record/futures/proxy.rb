module ActiveRecord
  module Futures
    class Proxy
      attr_reader :proxied

      def initialize(obj)
        @proxied = obj
      end

      def proxy?
        true
      end

      def ==(other)
        other = other.proxied if other.is_a? self.class
        @proxied == other
      end

      def !=(other)
        other = other.proxied if other.is_a? self.class
        @proxied != other
      end

      def method_missing(method, *args, &block)
        if @proxied.respond_to?(method)
          @proxied.send(method, *args, &block)
        else
          super
        end
      end

      def respond_to?(method, include_all = false)
        method.to_sym == :proxy? || super || @proxied.respond_to?(method, include_all)
      end
    end
  end
end