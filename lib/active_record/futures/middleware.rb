module ActiveRecord
  module Futures
    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        FutureRegistry.clear
        @app.call(env)
      end
    end
  end
end