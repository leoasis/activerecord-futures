require 'spec_helper'

describe "future_all method" do
  context "with no parameters" do
    let(:relation) { Post.where("published_at < ?", Time.new(2013, 1, 1)) }
    let(:all) { relation.future_all }
    let(:all_execution) { all.send(:future_execution) }
    let(:all_sql) do
      relation.to_sql
    end

    before do
      Post.create(published_at: Time.new(2012, 12, 10))
      Post.create(published_at: Time.new(2012, 6, 23))
      Post.create(published_at: Time.new(2013, 4, 5))
    end

    describe "#to_a" do
      let(:calling_to_a) { -> { all.to_a } }

      specify(nil, :supporting_adapter) { all_execution.should_not be_fulfilled }

      specify do
        calling_to_a.should exec(1).query
      end

      specify do
        calling_to_a.should exec_query(all_sql)
      end

      specify { all.to_a.should eq relation.all }

      context "after executing the future" do
        before do
          all.to_a
        end

        specify(nil, :supporting_adapter) { all_execution.should be_fulfilled }
      end

      context "executing it twice" do
        before do
          all.to_a
        end

        specify do
          calling_to_a.should exec(0).queries
        end

        specify { all.to_a.should eq relation.all }
      end
    end
  end
end