class Post < ActiveRecord::Base
  default_scope { where("published_at is not null") }
end