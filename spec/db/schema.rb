ActiveRecord::Schema.define(:version => 1) do

  create_table "countries", :force => true do |t|
    t.string   "name"
    t.boolean   "active"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end