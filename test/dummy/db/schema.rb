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

ActiveRecord::Schema.define(version: 20160617084101) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "intarray"
  enable_extension "pg_trgm"
  enable_extension "uuid-ossp"

  create_table "openbill_accounts", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "owner_id"
    t.uuid     "category_id",                                      null: false
    t.string   "key",                limit: 256,                   null: false
    t.decimal  "amount_cents",                   default: 0.0,     null: false
    t.string   "amount_currency",    limit: 3,   default: "USD",   null: false
    t.text     "details"
    t.integer  "transactions_count",             default: 0,       null: false
    t.hstore   "meta",                           default: {},      null: false
    t.datetime "created_at",                     default: "now()"
    t.datetime "updated_at",                     default: "now()"
  end

  add_index "openbill_accounts", ["created_at"], name: "index_accounts_on_created_at", using: :btree
  add_index "openbill_accounts", ["id"], name: "index_accounts_on_id", unique: true, using: :btree
  add_index "openbill_accounts", ["key"], name: "index_accounts_on_key", unique: true, using: :btree
  add_index "openbill_accounts", ["meta"], name: "index_accounts_on_meta", using: :gin

  create_table "openbill_categories", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid   "owner_id"
    t.string "name",      limit: 256, null: false
    t.uuid   "parent_id"
  end

  add_index "openbill_categories", ["parent_id", "name"], name: "index_openbill_categories_name", unique: true, using: :btree

  create_table "openbill_operations", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.datetime "created_at",                  default: "now()"
    t.uuid     "from_account_id",                               null: false
    t.uuid     "to_account_id",                                 null: false
    t.uuid     "owner_id"
    t.string   "key",             limit: 256,                   null: false
    t.text     "details",                                       null: false
    t.hstore   "meta",                        default: {},      null: false
  end

  create_table "openbill_policies", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string  "name",             limit: 256,                null: false
    t.uuid    "from_category_id"
    t.uuid    "to_category_id"
    t.uuid    "from_account_id"
    t.uuid    "to_account_id"
    t.boolean "allow_reverse",                default: true, null: false
  end

  add_index "openbill_policies", ["name"], name: "index_openbill_policies_name", unique: true, using: :btree

  create_table "openbill_transactions", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "operation_id"
    t.uuid     "owner_id"
    t.string   "username",               limit: 255,                   null: false
    t.date     "date",                                                 null: false
    t.datetime "created_at",                         default: "now()"
    t.uuid     "from_account_id",                                      null: false
    t.uuid     "to_account_id",                                        null: false
    t.decimal  "amount_cents",                                         null: false
    t.string   "amount_currency",        limit: 3,                     null: false
    t.string   "key",                    limit: 256,                   null: false
    t.text     "details",                                              null: false
    t.hstore   "meta",                               default: {},      null: false
    t.uuid     "reverse_transaction_id"
  end

  add_index "openbill_transactions", ["created_at"], name: "index_transactions_on_created_at", using: :btree
  add_index "openbill_transactions", ["key"], name: "index_transactions_on_key", unique: true, using: :btree
  add_index "openbill_transactions", ["meta"], name: "index_transactions_on_meta", using: :gin

  add_foreign_key "openbill_accounts", "openbill_categories", column: "category_id", name: "openbill_accounts_category_id_fkey", on_delete: :restrict
  add_foreign_key "openbill_categories", "openbill_categories", column: "parent_id", name: "openbill_categories_parent_id_fkey", on_delete: :restrict
  add_foreign_key "openbill_policies", "openbill_accounts", column: "from_account_id", name: "openbill_policies_from_account_id_fkey"
  add_foreign_key "openbill_policies", "openbill_accounts", column: "to_account_id", name: "openbill_policies_to_account_id_fkey"
  add_foreign_key "openbill_policies", "openbill_categories", column: "from_category_id", name: "openbill_policies_from_category_id_fkey"
  add_foreign_key "openbill_policies", "openbill_categories", column: "to_category_id", name: "openbill_policies_to_category_id_fkey"
  add_foreign_key "openbill_transactions", "openbill_accounts", column: "from_account_id", name: "openbill_transactions_from_account_id_fkey", on_update: :restrict, on_delete: :restrict
  add_foreign_key "openbill_transactions", "openbill_accounts", column: "to_account_id", name: "openbill_transactions_to_account_id_fkey"
  add_foreign_key "openbill_transactions", "openbill_operations", column: "operation_id", name: "openbill_transactions_operation_id_fkey", on_update: :restrict, on_delete: :restrict
  add_foreign_key "openbill_transactions", "openbill_transactions", column: "reverse_transaction_id", name: "reverse_transaction_foreign_key"
end
