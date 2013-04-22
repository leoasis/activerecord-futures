ActiveRecord::Schema.define(:version => 1) do

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "posts", :force => true do |t|
    t.string    "title"
    t.text      "body"
    t.datetime  "published_at"
    t.datetime  "created_at", :null => false
    t.datetime  "updated_at", :null => false
  end

  create_table "comments", :force => true do |t|
    t.string     "body"
    t.references "user"
    t.references "post"
    t.datetime   "created_at", :null => false
    t.datetime   "updated_at", :null => false
  end
end