require 'spec_helper'

describe "future_count method" do
  let(:relation) { Post.where("published_at < ?", Time.new(2013, 1, 1)) }
  let(:count) { relation.future_count }
  let(:count_sql) do
    arel = relation.arel
    arel.projections = []
    arel.project("COUNT(*)")
    arel.to_sql
  end

  describe "#value" do
    let(:value) { -> { count.value } }

    specify do
      value.should exec(1).query
    end

    specify do
      value.should exec_query(count_sql)
    end

    context "executing it twice" do
      before do
        count.value
      end

      specify do
        value.should exec(0).queries
      end
    end
  end
end