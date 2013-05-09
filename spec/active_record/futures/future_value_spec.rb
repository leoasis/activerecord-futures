require "spec_helper"

module ActiveRecord::Futures
  describe FutureValue do
    let(:future) do
      double(Future, execute: nil)
    end
    subject { FutureValue.new(future) }

    describe "#value" do
      before do
        subject.value
      end

      specify { future.should have_received(:execute) }
    end

    describe "#inspect" do
      before do
        subject.inspect
      end

      specify { future.should have_received(:execute) }
    end
  end
end