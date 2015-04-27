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

ActiveRecord::Schema.define(version: 20150427213024) do

  create_table "course_hole_tee_boxes", force: :cascade do |t|
    t.integer  "course_hole_id"
    t.string   "name"
    t.string   "description"
    t.integer  "yardage"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "course_tee_box_id"
  end

  add_index "course_hole_tee_boxes", ["course_hole_id"], name: "index_course_hole_tee_boxes_on_course_hole_id"

  create_table "course_holes", force: :cascade do |t|
    t.integer  "course_id"
    t.integer  "hole_number"
    t.integer  "par"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "mens_handicap",   default: 0
    t.integer  "womens_handicap", default: 0
  end

  add_index "course_holes", ["course_id"], name: "index_course_holes_on_course_id"

  create_table "course_holes_tournaments", id: false, force: :cascade do |t|
    t.integer "course_hole_id"
    t.integer "tournament_id"
  end

  add_index "course_holes_tournaments", ["course_hole_id"], name: "index_course_holes_tournaments_on_course_hole_id"
  add_index "course_holes_tournaments", ["tournament_id"], name: "index_course_holes_tournaments_on_tournament_id"

  create_table "course_tee_boxes", force: :cascade do |t|
    t.integer  "course_id"
    t.string   "name"
    t.float    "rating",     default: 0.0
    t.integer  "slope",      default: 0
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "course_tee_boxes", ["course_id"], name: "index_course_tee_boxes_on_course_id"

  create_table "courses", force: :cascade do |t|
    t.string   "name"
    t.string   "phone_number"
    t.string   "street_address_1"
    t.string   "street_address_2"
    t.string   "city"
    t.string   "us_state"
    t.string   "postal_code"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "flights", force: :cascade do |t|
    t.integer  "tournament_id"
    t.integer  "flight_number"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "lower_bound"
    t.integer  "upper_bound"
  end

  add_index "flights", ["tournament_id"], name: "index_flights_on_tournament_id"

  create_table "flights_users", id: false, force: :cascade do |t|
    t.integer "flight_id"
    t.integer "user_id"
  end

  add_index "flights_users", ["flight_id"], name: "index_flights_users_on_flight_id"
  add_index "flights_users", ["user_id"], name: "index_flights_users_on_user_id"

  create_table "golf_outings", force: :cascade do |t|
    t.integer  "team_id"
    t.integer  "user_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.boolean  "has_paid",          default: false
    t.integer  "course_tee_box_id"
  end

  add_index "golf_outings", ["team_id"], name: "index_golf_outings_on_team_id"
  add_index "golf_outings", ["user_id"], name: "index_golf_outings_on_user_id"

  create_table "league_memberships", force: :cascade do |t|
    t.integer  "league_id"
    t.integer  "user_id"
    t.boolean  "is_admin",   default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "state"
  end

  add_index "league_memberships", ["league_id"], name: "index_league_memberships_on_league_id"
  add_index "league_memberships", ["user_id"], name: "index_league_memberships_on_user_id"

  create_table "leagues", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.float    "dues_amount", default: 0.0
  end

  create_table "payouts", force: :cascade do |t|
    t.integer  "flight_id"
    t.integer  "user_id"
    t.decimal  "amount"
    t.float    "points"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "sort_order", default: 0
  end

  add_index "payouts", ["flight_id"], name: "index_payouts_on_flight_id"

  create_table "scorecards", force: :cascade do |t|
    t.integer  "golf_outing_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "is_confirmed",   default: false
  end

  add_index "scorecards", ["golf_outing_id"], name: "index_scorecards_on_golf_outing_id"

  create_table "scores", force: :cascade do |t|
    t.integer  "scorecard_id"
    t.integer  "course_hole_id"
    t.integer  "strokes",        default: 0
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "sort_order",     default: 0
  end

  add_index "scores", ["course_hole_id"], name: "index_scores_on_course_hole_id"
  add_index "scores", ["scorecard_id"], name: "index_scores_on_scorecard_id"

  create_table "teams", force: :cascade do |t|
    t.integer  "tournament_group_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "teams", ["tournament_group_id"], name: "index_teams_on_tournament_group_id"

  create_table "tournament_groups", force: :cascade do |t|
    t.integer  "tournament_id"
    t.datetime "tee_time_at"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "max_number_of_players", default: 4
  end

  add_index "tournament_groups", ["tournament_id"], name: "index_tournament_groups_on_tournament_id"

  create_table "tournaments", force: :cascade do |t|
    t.integer  "league_id"
    t.integer  "course_id"
    t.string   "name"
    t.datetime "tournament_at"
    t.datetime "signup_opens_at"
    t.datetime "signup_closes_at"
    t.integer  "max_players"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.float    "dues_amount",       default: 0.0
    t.integer  "mens_tee_box_id"
    t.integer  "womens_tee_box_id"
    t.boolean  "is_finalized",      default: false
  end

  add_index "tournaments", ["course_id"], name: "index_tournaments_on_course_id"
  add_index "tournaments", ["league_id"], name: "index_tournaments_on_league_id"

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "is_super_user",          default: false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.string   "street_address_1"
    t.string   "street_address_2"
    t.string   "city"
    t.string   "us_state"
    t.string   "postal_code"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      default: 0
    t.integer  "current_league_id"
    t.float    "handicap_index",         default: 0.0
    t.boolean  "has_paid",               default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count"
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
