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

ActiveRecord::Schema[7.2].define(version: 2025_04_21_190705) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "discounts", force: :cascade do |t|
    t.string "item_code", null: false
    t.string "discount_type", null: false
    t.integer "min_quantity"
    t.float "discount_percentage"
    t.integer "increment_step"
    t.float "discount_per_step"
    t.float "max_percentage_discount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_code"], name: "index_discounts_on_item_code"
  end

  create_table "inventories", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.float "price"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_inventories_on_code", unique: true
  end
end
