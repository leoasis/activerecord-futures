require "spec_helper"

module ActiveRecord::Futures
  describe Future do
    let(:relation) do
      double(ActiveRecord::Relation, {
         connection: double("connection", supports_futures?: true)
      })
    end

    let(:query) { double("A query") }
    let(:binds) { double("Some query binds") }
    let(:execution) { double("The query execution", call: nil) }

    subject { Future.new(relation, query, binds, execution) }

    describe ".new" do
      before { FutureRegistry.stub(:register) }
      before { subject }

      it "gets registered" do
        FutureRegistry.should have_received(:register).with(subject)
      end

      its(:query) { should eq query }
      its(:binds) { should eq binds }

      it { should_not be_fulfilled }
    end

    describe "#fulfill" do
      let(:result) { "Some cool result" }

      before do
        subject.fulfill(result)
      end

      it { should be_fulfilled }
    end

    describe "#load" do
      before do
        execution.stub(:call) do
          @current_future = FutureRegistry.current
          nil
        end

        subject.load
      end

      it "calls the execution" do
        execution.should have_received(:call)
      end

      it "sets the current future to itself while execution was being called in the relation" do
        @current_future.should == subject
      end

      it "sets to nil the current future afterwards" do
        FutureRegistry.current.should == nil
      end
    end
  end
end