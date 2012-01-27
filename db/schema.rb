# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120127222929) do

  create_table "campaign_targets", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "group"
    t.string   "last_campaign"
    t.datetime "emailed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.integer  "request_id"
    t.integer  "user_id"
    t.integer  "donor_id"
    t.string   "type"
    t.string   "detail"
    t.text     "message"
    t.datetime "happened_at"
    t.datetime "notified_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public"
  end

  add_index "events", ["donor_id"], :name => "index_events_on_donor_id"
  add_index "events", ["request_id"], :name => "index_events_on_request_id"
  add_index "events", ["user_id"], :name => "index_events_on_user_id"

  create_table "pledges", :force => true do |t|
    t.integer  "user_id"
    t.integer  "quantity"
    t.text     "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pledges", ["user_id"], :name => "index_pledges_on_user_id"

  create_table "requests", :force => true do |t|
    t.integer  "user_id"
    t.string   "book"
    t.text     "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "donor_id"
    t.boolean  "flagged"
    t.boolean  "thanked"
    t.string   "status"
  end

  add_index "requests", ["user_id"], :name => "index_requests_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.string   "location"
    t.string   "school"
    t.string   "studying"
    t.text     "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
