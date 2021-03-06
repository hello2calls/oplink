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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20130910154741) do

  create_table "csn_customers", force: :cascade do |t|
    t.datetime "activation_date"
    t.datetime "expiration_date"
    t.string   "address",         limit: 255
    t.string   "first",           limit: 255
    t.string   "last",            limit: 255
    t.string   "email",           limit: 255
    t.string   "city",            limit: 255
    t.string   "country",         limit: 255
    t.string   "phone",           limit: 255
    t.integer  "customer_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "customers", force: :cascade do |t|
    t.string   "status",          limit: 255
    t.string   "phone",           limit: 255
    t.datetime "activation_date"
    t.datetime "expiration_date"
    t.string   "first",           limit: 255
    t.string   "last",            limit: 255
    t.string   "city",            limit: 255
    t.string   "country",         limit: 255
    t.string   "email",           limit: 255
    t.string   "address",         limit: 255
    t.float    "balance",         limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "opus", force: :cascade do |t|
    t.integer  "customer_id",     limit: 4
    t.string   "sn",              limit: 255
    t.datetime "activation_date"
    t.datetime "expiration_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",          limit: 255
  end

  create_table "payments", force: :cascade do |t|
    t.integer  "customer_id", limit: 4
    t.integer  "opu_id",      limit: 4
    t.float    "amount",      limit: 24
    t.datetime "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "opu_sn",      limit: 255
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
