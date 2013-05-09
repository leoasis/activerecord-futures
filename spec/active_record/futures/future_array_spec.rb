require "spec_helper"

module ActiveRecord::Futures
  describe FutureArray do
    let(:future) do
      double(Future, execute: nil)
    end
    subject { FutureArray.new(future) }

    describe "#to_a" do
      before do
        subject.to_a
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