require 'spec_helper'

describe "future_count method" do
  context "single value count" do
    let(:relation) { Post.where("published_at < ?", Time.new(2013, 1, 1)) }
    let(:future) { relation.future_count }
    let(:relation_result) { relation.count }
    let(:future_sql) do
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

    it_behaves_like "a futurized method", :value
  end

  context "grouped value count" do
    let(:relation) { Comment.scoped }
    let(:future) { relation.future_count(group: :post_id) }
    let(:relation_result) { relation.count(group: :post_id) }
    let(:future_sql) do
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

    it_behaves_like "a futurized method", :value
  end
end