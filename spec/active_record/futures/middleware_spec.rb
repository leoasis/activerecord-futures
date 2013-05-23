require 'spec_helper'
require 'active_record/futures/middleware'

module ActiveRecord::Futures
  describe Middleware do
    let(:app) { double("Rack Application", call: nil) }
    let(:env) { double("App environment") }

    subject(:middleware) { Middleware.new(app) }

    before do
      FutureRegistry.stub(:clear)
    end

    context "normal flow" do
      before do
        middleware.call(env)
      end

      it "resets the registry" do
        FutureRegistry.should have_received(:clear)
      end

      it "continues calling the middleware stack" do
        app.should have_received(:call).with(env)
      end
    end

    context "when app.call raises exception" do
      before do
        app.stub(:call).and_raise("some error")
        begin
          middleware.call(env)
        rescue
        end
      end

      it "still clears the registry" do
        FutureRegistry.should have_received(:clear)
      end
    end
  end
end