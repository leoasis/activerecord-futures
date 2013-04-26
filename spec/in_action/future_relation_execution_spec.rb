require "spec_helper"

describe "future method" do

  before do
    Post.create(published_at: Time.new(2012, 12, 10))
    Post.create(published_at: Time.new(2012, 6, 23))
    Post.create(published_at: Time.new(2013, 4, 5))
  end

  def self.spec_relation(description, relation_lambda, &block)
    context "with a sample relation that #{description}" do
      let(:relation) { relation_lambda.call }
      let(:future) { relation.future }

      describe "#to_a" do
        let(:calling_to_a) { lambda { future.to_a } }

        specify do
          calling_to_a.should exec(1).query
        end

        specify do
          calling_to_a.should exec_query(relation.to_sql)
        end

        instance_eval(&block)

        context "executing it twice" do
          before do
            future.to_a
          end

          specify do
            calling_to_a.should exec(0).queries
          end

          instance_eval(&block)
        end
      end
    end
  end

  spec_relation "filters by published_at", -> { Post.where("published_at < ?", Time.new(2013, 1, 1)) } do
    specify { future.to_a.should have(2).posts }
  end

  spec_relation "limits by 10", -> { Post.limit(10) } do
    specify { future.to_a.should have(3).posts }
  end

end