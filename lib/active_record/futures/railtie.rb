module ActiveRecord
  module Futures
    class Railtie < ::Rails::Railtie
      config.app_middleware.use Middleware
    end
  end
end