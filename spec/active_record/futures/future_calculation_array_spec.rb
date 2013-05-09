require "spec_helper"

module ActiveRecord::Futures
  describe FutureCalculationArray do
    let(:relation) do
      double(ActiveRecord::Relation, {
        klass: Class.new,
        arel: nil,
        connection: double("connection", supports_futures?: true)
      })
    end

    let(:query) { "select 1" }
    let(:exec_result) { double("exec result", inspect: nil) }
    let(:exec) { ->{ exec_result } }

    subject { FutureCalculationArray.new(relation, query, nil, exec) }

    describe "#inspect" do
      before do
        subject.inspect
      end

      it { should be_executed }

      it "delegates to exec result's inspect" do
        exec_result.should have_received(:inspect)
      end
    end

    describe "unknown method" do
      let(:method_call) { ->{ subject.unknown } }
      specify { method_call.should raise_error(NoMethodError) }
    end
  end
end