require "spec_helper"

describe "future method" do
  let(:relation) { User.where("id > 10") }
  let(:future) { relation.future }

  describe "#to_a" do
    let(:to_a) { lambda { future.to_a } }

    specify do
      to_a.should exec(1).query
    end

    specify do
      to_a.should exec_query(relation.to_sql)
    end

    context "executing it twice" do
      before do
        future.to_a
      end

      specify do
        to_a.should exec(0).queries
      end
    end
  end
end