require 'spec_helper'

describe "future_count method" do
  context "single value count" do
    let(:relation) { Post.where("published_at < ?", Time.new(2013, 1, 1)) }
    let(:count) { relation.future_count }
    let(:count_sql) do
      arel = relation.arel
      arel.projections = []
      arel.project("COUNT(*)")
      arel.to_sql
    end

    before do
      Post.create(published_at: Time.new(2012, 12, 10))
      Post.create(published_at: Time.new(2012, 6, 23))
      Post.create(published_at: Time.new(2013, 4, 5))
    end

    describe "#value" do
      let(:calling_value) { -> { count.value } }

      specify do
        calling_value.should exec(1).query
      end

      specify do
        calling_value.should exec_query(count_sql)
      end

      specify { count.value.should eq 2 }

      context "executing it twice" do
        before do
          count.value
        end

        specify do
          calling_value.should exec(0).queries
        end

        specify { count.value.should eq 2 }
      end
    end
  end

  context "grouped value count" do
    let(:relation) { Comment.scoped }
    let(:count) { relation.future_count(group: :post_id) }
    let(:count_sql) do
      arel = relation.arel
      arel.projections = []
      arel.project("COUNT(*) AS count_all")
      arel.project("post_id AS post_id")
      arel.group("post_id")
      arel.to_sql
    end

    let(:post_1) { Post.create(published_at: Time.now) }
    let(:post_2) { Post.create(published_at: Time.now) }

    before do
      Comment.create(post: post_1)
      Comment.create(post: post_1)
      Comment.create(post: post_2)
      Comment.create(post: post_2)
      Comment.create(post: post_2)
    end

    describe "#to_a" do
      let(:calling_to_a) { -> { count.to_a } }

      specify do
        calling_to_a.should exec(1).query
      end

      specify do
        calling_to_a.should exec_query(count_sql)
      end

      specify { count.to_a[post_1.id].should eq 2 }
      specify { count.to_a[post_2.id].should eq 3 }

      context "executing it twice" do
        before do
          count.to_a
        end

        specify do
          calling_to_a.should exec(0).queries
        end

        specify { count.to_a[post_1.id].should eq 2 }
        specify { count.to_a[post_2.id].should eq 3 }
      end
    end
  end
end