require 'spec_helper'

describe "future_all method" do
  context "with no parameters" do
    let(:relation) { Post.where("published_at < ?", Time.new(2013, 1, 1)) }
    let(:find) { relation.future_all }
    let(:find_sql) do
      relation.to_sql
    end

    before do
      Post.create(published_at: Time.new(2012, 12, 10))
      Post.create(published_at: Time.new(2012, 6, 23))
      Post.create(published_at: Time.new(2013, 4, 5))
    end

    describe "#to_a" do
      let(:calling_to_a) { -> { find.to_a } }

      specify(nil, :supporting_adapter) { find.should_not be_fulfilled }

      specify do
        calling_to_a.should exec(1).query
      end

      specify do
        calling_to_a.should exec_query(find_sql)
      end

      specify { find.to_a.should eq relation.all }

      context "after executing the future" do
        before do
          find.to_a
        end

        specify(nil, :supporting_adapter) { find.should be_fulfilled }
      end

      context "executing it twice" do
        before do
          find.to_a
        end

        specify do
          calling_to_a.should exec(0).queries
        end

        specify { find.to_a.should eq relation.all }
      end
    end
  end
end