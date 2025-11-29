# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_11_29_172133) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "return_requests", force: :cascade do |t|
    t.jsonb "ai_classification"
    t.datetime "created_at", null: false
    t.string "currency"
    t.string "customer_id"
    t.string "decision"
    t.text "description"
    t.jsonb "metadata"
    t.string "order_id"
    t.integer "order_value_cents"
    t.string "reason"
    t.string "resolution"
    t.datetime "updated_at", null: false
  end

  create_table "rules", force: :cascade do |t|
    t.jsonb "actions"
    t.boolean "active"
    t.jsonb "conditions"
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "priority"
    t.datetime "updated_at", null: false
  end
end
