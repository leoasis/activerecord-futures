require "spec_helper"

module ActiveRecord::Futures
  describe Proxy do

    let(:obj) { Object.new }
    subject { Proxy.new(obj) }

    it "delegates method calls to the proxied object" do
      obj.should_receive(:inspect)

      subject.inspect
    end

    describe "#==" do
      it "is equal to the proxied object" do
        subject.should == obj
      end

      it "is equal to a proxy of the same object" do
        subject.should == Proxy.new(obj)
      end

      it "is not equal to another object" do
        subject.should_not == Object.new
      end

      it "is not equal to another object of another type" do
        subject.should_not == "A string object"
      end
    end

    describe "#!=" do
      it "is equal to the proxied object" do
        (subject != obj).should be_false
      end

      it "is equal to a proxy of the same object" do
        (subject != Proxy.new(obj)).should be_false
      end

      it "is not equal to another object" do
        (subject != Object.new).should be_true
      end

      it "is not equal to another object of another type" do
        (subject != "A string object").should be_true
      end
    end
  end
end