require 'spec_helper'

describe "future_find method" do
  context "finding by a single id" do
    let(:relation) { Post.where("published_at < ?", Time.new(2013, 1, 1)) }
    let(:future) { relation.future_find(@post_id) }
    let(:relation_result) { relation.find(@post_id) }
    let(:future_sql) do
      arel = relation.where(id: @post_id).arel
      arel.limit = 1
      arel.to_sql
    end

    let(:future_sql_postgresql) do
      arel = relation.arel
      arel.constraints.unshift(Arel.sql('"posts"."id" = $1'))
      arel.limit = 1
      arel.to_sql
    end

    let(:future_sql_sqlite3) do
      arel = relation.arel
      arel.constraints.unshift(Arel.sql('"posts"."id" = ?'))
      arel.limit = 1
      arel.to_sql
    end

    before do
      Post.create(published_at: Time.new(2012, 12, 10))
      Post.create(published_at: Time.new(2012, 6, 23))
      Post.create(published_at: Time.new(2013, 4, 5))
      @post_id = relation.first.id
    end

    it_behaves_like "a futurized method", :value
  end

  context "finding by multiple ids" do
    let(:relation) { Post.where("published_at < ?", Time.new(2013, 1, 1)) }
    let(:future) { relation.future_find(*@post_ids) }
    let(:relation_result) { relation.find(*@post_ids) }
    let(:future_sql) do
      arel = relation.where(id: @post_ids).arel
      arel.to_sql
    end

    before do
      Post.create(published_at: Time.new(2012, 12, 10))
      Post.create(published_at: Time.new(2012, 6, 23))
      Post.create(published_at: Time.new(2013, 4, 5))
      @post_ids = [relation.first.id, relation.last.id]
    end

    it_behaves_like "a futurized method", :to_a
  end

  context "finding by multiple ids, with single array parameter" do
    let(:relation) { Post.where("published_at < ?", Time.new(2013, 1, 1)) }
    let(:future) { relation.future_find(@post_ids) }
    let(:relation_result) { relation.find(@post_ids) }
    let(:future_sql) do
      arel = relation.where(id: @post_ids).arel
      arel.to_sql
    end

    before do
      Post.create(published_at: Time.new(2012, 12, 10))
      Post.create(published_at: Time.new(2012, 6, 23))
      Post.create(published_at: Time.new(2013, 4, 5))
      @post_ids = [relation.first.id, relation.last.id]
    end

    it_behaves_like "a futurized method", :to_a
  end
end