require 'spec_helper'

module ActiveRecord::Futures
  describe FutureRegistry do
    subject { FutureRegistry }

    describe ".futures" do
      context "with futures in two threads" do
        let(:futures_key) { "#{subject.name}_futures" }

        let(:a_thread) do
          thread = double("Thread 1")
          thread.stub(:[]).with(futures_key).and_return([])
          thread
        end

        let(:another_thread) do
          thread = double("Thread 2")
          thread.stub(:[]).with(futures_key).and_return([])
          thread
        end

        before do
          Thread.stub(:current).and_return(a_thread)

          subject.futures << "Future 1"
          subject.futures << "Future 2"

          Thread.stub(:current).and_return(another_thread)

          subject.futures << "Future 3"
          subject.futures << "Future 4"
        end

        context "the futures in thread 1" do
          let(:futures) { a_thread[futures_key] }

          specify { futures.should include("Future 1") }
          specify { futures.should include("Future 2") }
          specify { futures.should_not include("Future 3") }
          specify { futures.should_not include("Future 4") }
        end

        context "the futures in thread 2" do
          let(:futures) { another_thread[futures_key] }

          specify { futures.should_not include("Future 1") }
          specify { futures.should_not include("Future 2") }
          specify { futures.should include("Future 3") }
          specify { futures.should include("Future 4") }
        end
      end
    end

    describe ".current" do
      context "with currents in two threads" do
        let(:current_key) { "#{subject.name}_current" }

        let(:a_thread) { Hash.new }
        let(:another_thread) { Hash.new }

        before do
          Thread.stub(:current).and_return(a_thread)

          subject.current = "Future 1"

          Thread.stub(:current).and_return(another_thread)

          subject.current = "Future 2"
        end

        context "the current in thread 1" do
          let(:current) { a_thread[current_key] }

          specify { current.should eq "Future 1" }
        end

        context "the current in thread 2" do
          let(:current) { another_thread[current_key] }

          specify { current.should eq "Future 2" }
        end
      end
    end
  end
end