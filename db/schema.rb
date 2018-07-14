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

ActiveRecord::Schema.define(version: 20180714212936) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"

  create_table "contest_holes", id: :serial, force: :cascade do |t|
    t.integer "contest_id"
    t.integer "course_hole_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contest_id"], name: "index_contest_holes_on_contest_id"
    t.index ["course_hole_id"], name: "index_contest_holes_on_course_hole_id"
  end

  create_table "contest_results", id: :serial, force: :cascade do |t|
    t.integer "contest_id"
    t.integer "contest_hole_id"
    t.integer "winner_id"
    t.string "result_value"
    t.decimal "payout_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "points", default: 0
    t.index ["contest_hole_id"], name: "index_contest_results_on_contest_hole_id"
    t.index ["contest_id"], name: "index_contest_results_on_contest_id"
    t.index ["winner_id"], name: "index_contest_results_on_winner_id"
  end

  create_table "contests", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "contest_type"
    t.integer "overall_winner_contest_result_id"
    t.decimal "overall_winner_payout_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tournament_day_id"
    t.decimal "dues_amount", default: "0.0"
    t.integer "overall_winner_points", default: 0
    t.boolean "is_opt_in", default: false
    t.index ["overall_winner_contest_result_id"], name: "index_contests_on_overall_winner_contest_result_id"
    t.index ["tournament_day_id"], name: "index_contests_on_tournament_day_id"
  end

  create_table "contests_users", id: false, force: :cascade do |t|
    t.integer "contest_id"
    t.integer "user_id"
    t.index ["contest_id"], name: "index_contests_users_on_contest_id"
    t.index ["user_id"], name: "index_contests_users_on_user_id"
  end

  create_table "course_hole_tee_boxes", id: :serial, force: :cascade do |t|
    t.integer "course_hole_id"
    t.string "description"
    t.integer "yardage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "course_tee_box_id"
    t.index ["course_hole_id"], name: "index_course_hole_tee_boxes_on_course_hole_id"
    t.index ["course_tee_box_id"], name: "index_course_hole_tee_boxes_on_course_tee_box_id"
  end

  create_table "course_holes", id: :serial, force: :cascade do |t|
    t.integer "course_id"
    t.integer "hole_number"
    t.integer "par"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mens_handicap", default: 0
    t.integer "womens_handicap", default: 0
    t.index ["course_id"], name: "index_course_holes_on_course_id"
  end

  create_table "course_holes_tournament_days", id: false, force: :cascade do |t|
    t.integer "course_hole_id"
    t.integer "tournament_day_id"
    t.index ["course_hole_id"], name: "index_course_holes_tournament_days_on_course_hole_id"
    t.index ["tournament_day_id"], name: "index_course_holes_tournament_days_on_tournament_day_id"
  end

  create_table "course_tee_boxes", id: :serial, force: :cascade do |t|
    t.integer "course_id"
    t.string "name"
    t.float "rating", default: 0.0
    t.integer "slope", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tee_box_gender", default: "Men"
    t.index ["course_id"], name: "index_course_tee_boxes_on_course_id"
  end

  create_table "courses", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "phone_number"
    t.string "street_address_1"
    t.string "street_address_2"
    t.string "city"
    t.string "us_state"
    t.string "postal_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "latitude"
    t.float "longitude"
    t.string "import_tag"
    t.string "website_url"
    t.index ["name"], name: "index_courses_on_name"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "progress_stage"
    t.integer "progress_current", default: 0
    t.integer "progress_max", default: 0
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "flights", id: :serial, force: :cascade do |t|
    t.integer "flight_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lower_bound"
    t.integer "upper_bound"
    t.integer "course_tee_box_id"
    t.integer "tournament_day_id"
    t.integer "league_season_scoring_group_id"
    t.index ["course_tee_box_id"], name: "index_flights_on_course_tee_box_id"
    t.index ["flight_number"], name: "index_flights_on_flight_number"
    t.index ["league_season_scoring_group_id"], name: "index_flights_on_league_season_scoring_group_id"
    t.index ["tournament_day_id"], name: "index_flights_on_tournament_day_id"
  end

  create_table "flights_users", id: false, force: :cascade do |t|
    t.integer "flight_id"
    t.integer "user_id"
    t.index ["flight_id"], name: "index_flights_users_on_flight_id"
    t.index ["user_id"], name: "index_flights_users_on_user_id"
  end

  create_table "game_type_metadata", id: :serial, force: :cascade do |t|
    t.integer "course_hole_id"
    t.integer "scorecard_id"
    t.integer "golfer_team_id"
    t.string "search_key"
    t.string "string_value"
    t.integer "integer_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "float_value"
    t.index ["course_hole_id"], name: "index_game_type_metadata_on_course_hole_id"
    t.index ["golfer_team_id"], name: "index_game_type_metadata_on_golfer_team_id"
    t.index ["scorecard_id", "search_key"], name: "scorecard_search_key_index"
    t.index ["scorecard_id"], name: "index_game_type_metadata_on_scorecard_id"
    t.index ["search_key"], name: "index_game_type_metadata_on_search_key"
  end

  create_table "golf_outings", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_paid", default: false
    t.integer "course_tee_box_id"
    t.boolean "confirmed", default: false
    t.float "course_handicap", default: 0.0
    t.boolean "is_confirmed", default: false
    t.integer "tournament_group_id"
    t.boolean "disqualified", default: false
    t.string "registered_by"
    t.datetime "deleted_at"
    t.index ["course_tee_box_id"], name: "index_golf_outings_on_course_tee_box_id"
    t.index ["deleted_at"], name: "index_golf_outings_on_deleted_at"
    t.index ["is_confirmed"], name: "index_golf_outings_on_is_confirmed"
    t.index ["tournament_group_id"], name: "index_golf_outings_on_tournament_group_id"
    t.index ["user_id"], name: "index_golf_outings_on_user_id"
  end

  create_table "golfer_teams", id: :serial, force: :cascade do |t|
    t.integer "max_players", default: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "are_opponents", default: false
    t.integer "parent_team_id"
    t.integer "tournament_day_id"
    t.integer "tournament_group_id"
    t.string "team_number"
    t.index ["parent_team_id"], name: "index_golfer_teams_on_parent_team_id"
    t.index ["tournament_day_id"], name: "index_golfer_teams_on_tournament_day_id"
    t.index ["tournament_group_id"], name: "index_golfer_teams_tournament_group_id"
  end

  create_table "golfer_teams_users", id: false, force: :cascade do |t|
    t.integer "golfer_team_id"
    t.integer "user_id"
    t.index ["golfer_team_id"], name: "index_golfer_teams_users_on_golfer_team_id"
    t.index ["user_id"], name: "index_golfer_teams_users_on_user_id"
  end

  create_table "league_memberships", id: :serial, force: :cascade do |t|
    t.integer "league_id"
    t.integer "user_id"
    t.boolean "is_admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state"
    t.decimal "league_dues_discount", default: "0.0"
    t.datetime "deleted_at"
    t.float "course_handicap"
    t.index ["deleted_at"], name: "index_league_memberships_on_deleted_at"
    t.index ["league_id"], name: "index_league_memberships_on_league_id"
    t.index ["user_id"], name: "index_league_memberships_on_user_id"
  end

  create_table "league_season_scoring_groups", force: :cascade do |t|
    t.integer "league_season_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "league_season_scoring_groups_users", id: false, force: :cascade do |t|
    t.bigint "league_season_scoring_group_id", null: false
    t.bigint "user_id", null: false
    t.index ["league_season_scoring_group_id", "user_id"], name: "scoring_group_index"
  end

  create_table "league_seasons", id: :serial, force: :cascade do |t|
    t.integer "league_id"
    t.string "name"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "dues_amount", default: "0.0"
    t.index ["league_id"], name: "index_league_seasons_on_league_id"
  end

  create_table "leagues", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_stripe_test_secret_key"
    t.string "encrypted_stripe_production_secret_key"
    t.string "encrypted_stripe_test_publishable_key"
    t.string "encrypted_stripe_production_publishable_key"
    t.boolean "stripe_test_mode", default: true
    t.string "dues_payment_receipt_email_addresses"
    t.string "apple_pay_merchant_id"
    t.boolean "supports_apple_pay", default: false
    t.boolean "show_in_search", default: true
    t.string "league_description"
    t.string "contact_name"
    t.string "contact_phone"
    t.string "contact_email"
    t.string "location"
    t.string "required_container_frame_url"
    t.boolean "exempt_from_subscription", default: false
    t.string "stripe_token"
    t.string "cc_last_four"
    t.integer "cc_expire_month"
    t.integer "cc_expire_year"
    t.date "start_date"
    t.integer "free_tournaments_remaining", default: 2
    t.boolean "display_balances_to_players", default: true
    t.string "league_type"
    t.text "more_comments"
    t.boolean "allow_scoring_groups", default: false
  end

  create_table "mobile_devices", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "device_identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "device_type"
    t.string "environment_name"
    t.index ["device_identifier"], name: "index_mobile_devices_on_device_identifier"
    t.index ["user_id"], name: "index_mobile_devices_on_user_id"
  end

  create_table "notification_templates", id: :serial, force: :cascade do |t|
    t.integer "tournament_id"
    t.integer "league_id"
    t.string "title"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deliver_at"
    t.boolean "has_been_delivered", default: false
    t.boolean "notify_on_tournament_finalization", default: true
    t.boolean "notify_tournament_unregistered_players_before_closing", default: true
    t.string "tournament_notification_action"
    t.index ["league_id"], name: "index_league_id_on_notification_templates"
    t.index ["tournament_id"], name: "index_tournament_id_on_notification_templates"
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.integer "notification_template_id"
    t.integer "user_id"
    t.string "title"
    t.text "body"
    t.boolean "is_read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_template_id"], name: "index_notification_template_id_on_notifications"
    t.index ["user_id"], name: "index_user_id_on_notifications"
  end

  create_table "payments", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "tournament_id"
    t.decimal "payment_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "payment_type"
    t.string "payment_source"
    t.string "transaction_id"
    t.text "payment_details"
    t.integer "contest_id"
    t.integer "league_season_id"
    t.integer "payment_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_payments_on_deleted_at"
    t.index ["league_season_id"], name: "index_payments_on_league_season_id"
    t.index ["tournament_id"], name: "index_payments_on_tournament_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "payout_results", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "payout_id"
    t.integer "flight_id"
    t.integer "tournament_day_id"
    t.decimal "amount"
    t.float "points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_payout_results_on_deleted_at"
    t.index ["flight_id"], name: "index_payout_results_on_flight_id"
    t.index ["payout_id"], name: "index_payout_results_on_payout_id"
    t.index ["tournament_day_id"], name: "index_payout_results_on_tournament_day_id"
    t.index ["user_id"], name: "index_payout_results_on_user_id"
  end

  create_table "payouts", id: :serial, force: :cascade do |t|
    t.integer "flight_id"
    t.decimal "amount"
    t.float "points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sort_order", default: 0
    t.index ["flight_id"], name: "index_payouts_on_flight_id"
    t.index ["sort_order"], name: "index_payouts_on_sort_order"
  end

  create_table "scorecards", id: :serial, force: :cascade do |t|
    t.integer "golf_outing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_confirmed", default: false
    t.integer "designated_editor_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_scorecards_on_deleted_at"
    t.index ["golf_outing_id"], name: "index_scorecards_on_golf_outing_id"
  end

  create_table "scores", id: :serial, force: :cascade do |t|
    t.integer "scorecard_id"
    t.integer "course_hole_id"
    t.integer "strokes", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sort_order", default: 0
    t.boolean "has_notified", default: false
    t.datetime "deleted_at"
    t.index ["course_hole_id"], name: "index_scores_on_course_hole_id"
    t.index ["deleted_at"], name: "index_scores_on_deleted_at"
    t.index ["scorecard_id"], name: "index_scores_on_scorecard_id"
    t.index ["sort_order"], name: "index_scores_on_sort_order"
  end

  create_table "subscription_credits", id: :serial, force: :cascade do |t|
    t.decimal "amount"
    t.integer "golfer_count"
    t.string "transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "league_season_id"
  end

  create_table "tournament_day_results", id: :serial, force: :cascade do |t|
    t.integer "tournament_day_id"
    t.integer "user_id"
    t.integer "user_primary_scorecard_id"
    t.integer "flight_id"
    t.integer "gross_score"
    t.integer "net_score"
    t.integer "back_nine_net_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "front_nine_net_score"
    t.integer "front_nine_gross_score"
    t.integer "par_related_net_score"
    t.integer "par_related_gross_score"
    t.integer "adjusted_score", default: 0
    t.index ["flight_id"], name: "index_tournament_day_results_on_flight_id"
    t.index ["tournament_day_id"], name: "index_tournament_day_results_on_tournament_day_id"
    t.index ["user_id"], name: "index_tournament_day_results_on_user_id"
    t.index ["user_primary_scorecard_id"], name: "index_tournament_day_results_on_user_primary_scorecard_id"
  end

  create_table "tournament_days", id: :serial, force: :cascade do |t|
    t.integer "tournament_id"
    t.integer "course_id"
    t.integer "game_type_id"
    t.datetime "tournament_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin_has_customized_teams", default: false
    t.boolean "data_was_imported", default: false
    t.index ["course_id"], name: "index_tournament_days_on_course_id"
    t.index ["tournament_at"], name: "index_tournament_days_on_tournament_at"
    t.index ["tournament_id"], name: "index_tournament_days_on_tournament_id"
  end

  create_table "tournament_groups", id: :serial, force: :cascade do |t|
    t.datetime "tee_time_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "max_number_of_players", default: 4
    t.integer "tournament_day_id"
    t.index ["tournament_day_id"], name: "index_tournament_groups_on_tournament_day_id"
  end

  create_table "tournaments", id: :serial, force: :cascade do |t|
    t.integer "league_id"
    t.string "name"
    t.datetime "signup_opens_at"
    t.datetime "signup_closes_at"
    t.integer "max_players"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "dues_amount", default: "0.0"
    t.boolean "is_finalized", default: false
    t.boolean "show_players_tee_times", default: false
    t.integer "auto_schedule_for_multi_day", default: 1
    t.boolean "allow_credit_card_payment", default: true
    t.integer "tournament_days_count", default: 0
    t.datetime "tournament_starts_at"
    t.index ["league_id"], name: "index_tournaments_on_league_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: ""
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.boolean "is_super_user", default: false
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.string "street_address_1"
    t.string "street_address_2"
    t.string "city"
    t.string "us_state"
    t.string "postal_code"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.integer "invited_by_id"
    t.string "invited_by_type"
    t.integer "invitations_count", default: 0
    t.integer "current_league_id"
    t.float "handicap_index", default: 0.0
    t.string "ghin_number"
    t.string "session_token"
    t.boolean "wants_email_notifications", default: true
    t.boolean "wants_push_notifications", default: true
    t.datetime "ghin_updated_at"
    t.string "time_zone", default: "Pacific Time (US & Canada)"
    t.integer "parent_id"
    t.boolean "is_blocked", default: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
