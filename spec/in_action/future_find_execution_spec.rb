require 'spec_helper'

describe "future_find method" do
  context "finding by a single id" do
    let(:relation) { Post.where("published_at < ?", Time.new(2013, 1, 1)) }
    let(:find) { relation.future_find(@post_id) }
    let(:find_sql) do
      arel = relation.where(id: @post_id).arel
      arel.limit = 1
      arel.to_sql
    end

    let(:find_sql_postgresql) do
      arel = relation.arel
      arel.constraints.unshift(Arel.sql('"posts"."id" = $1'))
      arel.limit = 1
      arel.to_sql
    end

    before do
      Post.create(published_at: Time.new(2012, 12, 10))
      Post.create(published_at: Time.new(2012, 6, 23))
      Post.create(published_at: Time.new(2013, 4, 5))
      @post_id = relation.first.id
    end

    describe "#value" do
      let(:calling_value) { -> { find.value } }

      specify(nil, :supporting_adapter) { find.should_not be_fulfilled }

      specify do
        calling_value.should exec(1).query
      end

      specify(nil, postgresql: false) do
        calling_value.should exec_query(find_sql)
      end

      specify(nil, postgresql: true) do
        calling_value.should exec_query(find_sql_postgresql)
      end

      specify { find.value.should eq relation.find(@post_id) }

      context "after executing the future" do
        before do
          find.value
        end

        specify(nil, :supporting_adapter) { find.should be_fulfilled }
      end

      context "executing it twice" do
        before do
          find.value
        end

        specify do
          calling_value.should exec(0).queries
        end

        specify { find.value.should eq relation.find(@post_id) }
      end
    end
  end

  context "finding by multiple ids" do
    let(:relation) { Post.where("published_at < ?", Time.new(2013, 1, 1)) }
    let(:find) { relation.future_find(*@post_ids) }
    let(:find_sql) do
      arel = relation.where(id: @post_ids).arel
      arel.to_sql
    end

    before do
      Post.create(published_at: Time.new(2012, 12, 10))
      Post.create(published_at: Time.new(2012, 6, 23))
      Post.create(published_at: Time.new(2013, 4, 5))
      @post_ids = [relation.first.id, relation.last.id]
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

      specify { find.to_a.should eq relation.find(@post_ids) }

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

        specify { find.to_a.should eq relation.find(@post_ids) }
      end
    end
  end

  context "finding by multiple ids, with single array parameter" do
    let(:relation) { Post.where("published_at < ?", Time.new(2013, 1, 1)) }
    let(:find) { relation.future_find(@post_ids) }
    let(:find_sql) do
      arel = relation.where(id: @post_ids).arel
      arel.to_sql
    end

    before do
      Post.create(published_at: Time.new(2012, 12, 10))
      Post.create(published_at: Time.new(2012, 6, 23))
      Post.create(published_at: Time.new(2013, 4, 5))
      @post_ids = [relation.first.id, relation.last.id]
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

      specify { find.to_a.should eq relation.find(@post_ids) }

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

        specify { find.to_a.should eq relation.find(@post_ids) }
      end
    end
  end
end