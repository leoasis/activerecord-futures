require "spec_helper"

module ActiveRecord::Futures
  describe FutureRelation do
    let(:relation) do
      double(ActiveRecord::Relation, {
        klass: Class.new,
        arel: nil,
        to_a: nil,
        to_sql: "select 1",
        connection: double("connection", supports_futures?: true)
      })
    end

    subject { FutureRelation.new(relation) }

    describe ".new" do
      before do
        subject
      end

      it "gets registered" do
        Future.all.should have(1).future
        Future.all.first.should == subject
      end

      its(:relation) { should eq relation }

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
        relation.stub(:to_a) do
          @current_future = Future.current
          nil
        end

        subject.load
      end

      it "calls #to_a in the relation" do
        relation.should have_received(:to_a)
      end

      it "sets the current future to itself while #to_a was being called in the relation" do
        @current_future.should == subject
      end

      it "sets to nil the current future afterwards" do
        Future.current.should == nil
      end
    end

    describe "#inspect" do
      let(:resulting_array) { double(Array, inspect: nil) }

      before do
        relation.stub(loaded?: true)
        relation.stub(:to_a).and_return(resulting_array)

        subject.inspect
      end

      it { should be_executed }

      it "delegates to relation.to_a.inspect" do
        resulting_array.should have_received(:inspect)
      end
    end

    describe "unknown method" do
      let(:method_call) { ->{ subject.unknown } }
      specify { method_call.should raise_error(NoMethodError) }
    end
  end
end