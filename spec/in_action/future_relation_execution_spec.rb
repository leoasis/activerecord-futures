require "spec_helper"

describe "future method" do
  examples = [
    -> { Post.where("published_at < ?", Time.new(2013, 1, 1)) },
    -> { Post.limit(10) }
  ]

  examples.each do |example|
    context "with a sample relation that queries #{example.call.to_sql}" do
      let(:relation) { example.call }
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
  end
end