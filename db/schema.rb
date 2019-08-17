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

ActiveRecord::Schema.define(version: 2019_08_17_201543) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "contests_users", id: false, force: :cascade do |t|
    t.bigint "contest_id"
    t.bigint "user_id"
    t.index ["contest_id"], name: "index_contests_users_on_contest_id"
    t.index ["user_id"], name: "index_contests_users_on_user_id"
  end

  create_table "course_hole_tee_boxes", force: :cascade do |t|
    t.bigint "course_hole_id"
    t.string "description"
    t.integer "yardage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "course_tee_box_id"
    t.index ["course_hole_id"], name: "index_course_hole_tee_boxes_on_course_hole_id"
    t.index ["course_tee_box_id"], name: "index_course_hole_tee_boxes_on_course_tee_box_id"
  end

  create_table "course_holes", force: :cascade do |t|
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
    t.bigint "course_hole_id"
    t.bigint "tournament_day_id"
    t.index ["course_hole_id"], name: "index_course_holes_tournament_days_on_course_hole_id"
    t.index ["tournament_day_id"], name: "index_course_holes_tournament_days_on_tournament_day_id"
  end

  create_table "course_tee_boxes", force: :cascade do |t|
    t.bigint "course_id"
    t.string "name"
    t.float "rating", default: 0.0
    t.integer "slope", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tee_box_gender", default: "Men"
    t.index ["course_id"], name: "index_course_tee_boxes_on_course_id"
  end

  create_table "courses", force: :cascade do |t|
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
    t.string "country"
    t.index ["name"], name: "index_courses_on_name"
  end

  create_table "daily_teams", force: :cascade do |t|
    t.integer "max_players", default: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "are_opponents", default: false
    t.bigint "parent_team_id"
    t.bigint "tournament_group_id"
    t.string "team_number"
    t.index ["parent_team_id"], name: "index_daily_teams_on_parent_team_id"
    t.index ["tournament_group_id"], name: "index_golfer_teams_tournament_group_id"
  end

  create_table "daily_teams_users", id: false, force: :cascade do |t|
    t.bigint "daily_team_id"
    t.bigint "user_id"
    t.index ["daily_team_id"], name: "index_daily_teams_users_on_daily_team_id"
    t.index ["user_id"], name: "index_daily_teams_users_on_user_id"
  end

  create_table "flights", force: :cascade do |t|
    t.integer "flight_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lower_bound"
    t.integer "upper_bound"
    t.bigint "course_tee_box_id"
    t.bigint "tournament_day_id"
    t.bigint "league_season_scoring_group_id"
    t.index ["course_tee_box_id"], name: "index_flights_on_course_tee_box_id"
    t.index ["flight_number"], name: "index_flights_on_flight_number"
    t.index ["league_season_scoring_group_id"], name: "index_flights_on_league_season_scoring_group_id"
    t.index ["tournament_day_id"], name: "index_flights_on_tournament_day_id"
  end

  create_table "flights_users", id: false, force: :cascade do |t|
    t.bigint "flight_id"
    t.bigint "user_id"
    t.index ["flight_id"], name: "index_flights_users_on_flight_id"
    t.index ["user_id"], name: "index_flights_users_on_user_id"
  end

  create_table "game_type_metadata", force: :cascade do |t|
    t.bigint "course_hole_id"
    t.bigint "scorecard_id"
    t.bigint "daily_team_id"
    t.string "search_key"
    t.string "string_value"
    t.integer "integer_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "float_value"
    t.index ["course_hole_id"], name: "index_game_type_metadata_on_course_hole_id"
    t.index ["daily_team_id"], name: "index_game_type_metadata_on_daily_team_id"
    t.index ["scorecard_id", "search_key"], name: "scorecard_search_key_index"
    t.index ["scorecard_id"], name: "index_game_type_metadata_on_scorecard_id"
    t.index ["search_key"], name: "index_game_type_metadata_on_search_key"
  end

  create_table "golf_outings", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_paid", default: false
    t.bigint "course_tee_box_id"
    t.boolean "confirmed", default: false
    t.float "course_handicap", default: 0.0
    t.boolean "is_confirmed", default: false
    t.bigint "tournament_group_id"
    t.boolean "disqualified", default: false
    t.string "registered_by"
    t.datetime "deleted_at"
    t.boolean "handicap_lock", default: false
    t.index ["course_tee_box_id"], name: "index_golf_outings_on_course_tee_box_id"
    t.index ["deleted_at"], name: "index_golf_outings_on_deleted_at"
    t.index ["disqualified"], name: "index_golf_outings_on_disqualified"
    t.index ["is_confirmed"], name: "index_golf_outings_on_is_confirmed"
    t.index ["tournament_group_id"], name: "index_golf_outings_on_tournament_group_id"
    t.index ["user_id"], name: "index_golf_outings_on_user_id"
  end

  create_table "league_memberships", force: :cascade do |t|
    t.bigint "league_id"
    t.bigint "user_id"
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

  create_table "league_season_ranking_groups", force: :cascade do |t|
    t.bigint "league_season_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["league_season_id"], name: "index_league_season_id"
  end

  create_table "league_season_rankings", force: :cascade do |t|
    t.bigint "league_season_ranking_group_id"
    t.bigint "user_id"
    t.integer "points", default: 0
    t.decimal "payouts", default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rank", default: 0
    t.bigint "league_season_team_id"
    t.integer "average_score", default: 0
    t.index ["league_season_ranking_group_id"], name: "index_league_season_ranking_group_id"
    t.index ["league_season_team_id"], name: "index_league_season_rankings_on_league_season_team_id"
    t.index ["user_id"], name: "index_league_season_ranking_group_user_id"
  end

  create_table "league_season_scoring_groups", force: :cascade do |t|
    t.bigint "league_season_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "league_season_scoring_groups_users", id: false, force: :cascade do |t|
    t.bigint "league_season_scoring_group_id", null: false
    t.bigint "user_id", null: false
    t.index ["league_season_scoring_group_id", "user_id"], name: "scoring_group_index"
  end

  create_table "league_season_team_memberships", force: :cascade do |t|
    t.bigint "league_season_team_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["league_season_team_id"], name: "index_league_season_team_memberships_on_league_season_team_id"
    t.index ["user_id"], name: "index_league_season_team_memberships_on_user_id"
  end

  create_table "league_season_team_tournament_day_matchups", force: :cascade do |t|
    t.bigint "league_season_team_a_id"
    t.bigint "league_season_team_b_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tournament_day_id"
    t.bigint "league_team_winner_id"
    t.string "excluded_user_ids"
    t.string "team_a_final_sort"
    t.string "team_b_final_sort"
    t.index ["league_season_team_a_id"], name: "league_season_team_a_id_index"
    t.index ["league_season_team_a_id"], name: "league_season_team_b_id_index"
    t.index ["league_team_winner_id"], name: "league_team_winner_id_index"
    t.index ["tournament_day_id"], name: "tournament_day_index"
  end

  create_table "league_season_teams", force: :cascade do |t|
    t.bigint "league_season_id"
    t.string "name"
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["league_season_id"], name: "index_league_season_teams_on_league_season_id"
  end

  create_table "league_seasons", force: :cascade do |t|
    t.bigint "league_id"
    t.string "name"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "dues_amount", default: "0.0"
    t.integer "season_type_raw", default: 0
    t.boolean "rankings_by_scoring_average", default: false
    t.index ["league_id"], name: "index_league_seasons_on_league_id"
  end

  create_table "leagues", force: :cascade do |t|
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
    t.boolean "calculate_handicaps_from_past_rounds", default: false
    t.decimal "override_golfer_price"
    t.string "league_estimated_players"
    t.integer "number_of_rounds_to_handicap"
    t.integer "number_of_lowest_rounds_to_handicap", default: 10
    t.boolean "use_equitable_stroke_control", default: true
  end

  create_table "mobile_devices", force: :cascade do |t|
    t.bigint "user_id"
    t.string "device_identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "device_type"
    t.string "environment_name"
    t.index ["device_identifier"], name: "index_mobile_devices_on_device_identifier"
    t.index ["user_id"], name: "index_mobile_devices_on_user_id"
  end

  create_table "notification_templates", force: :cascade do |t|
    t.bigint "tournament_id"
    t.bigint "league_id"
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

  create_table "notifications", force: :cascade do |t|
    t.bigint "notification_template_id"
    t.bigint "user_id"
    t.string "title"
    t.text "body"
    t.boolean "is_read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_template_id"], name: "index_notification_template_id_on_notifications"
    t.index ["user_id"], name: "index_user_id_on_notifications"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "tournament_id"
    t.decimal "payment_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "payment_type"
    t.string "payment_source"
    t.string "transaction_id"
    t.text "payment_details"
    t.bigint "contest_id"
    t.bigint "league_season_id"
    t.bigint "payment_id"
    t.datetime "deleted_at"
    t.bigint "scoring_rule_id"
    t.index ["deleted_at"], name: "index_payments_on_deleted_at"
    t.index ["league_season_id"], name: "index_payments_on_league_season_id"
    t.index ["tournament_id"], name: "index_payments_on_tournament_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "payout_results", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "payout_id"
    t.bigint "flight_id"
    t.decimal "amount"
    t.float "points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.bigint "scoring_rule_id"
    t.bigint "scoring_rule_course_hole_id"
    t.string "detail"
    t.bigint "league_season_team_id"
    t.integer "sorting_hint"
    t.index ["deleted_at"], name: "index_payout_results_on_deleted_at"
    t.index ["flight_id"], name: "index_payout_results_on_flight_id"
    t.index ["league_season_team_id"], name: "index_payout_results_on_league_season_team_id"
    t.index ["payout_id"], name: "index_payout_results_on_payout_id"
    t.index ["scoring_rule_id"], name: "index_payout_results_on_scoring_rule_id"
    t.index ["user_id"], name: "index_payout_results_on_user_id"
  end

  create_table "payouts", force: :cascade do |t|
    t.bigint "flight_id"
    t.decimal "amount"
    t.float "points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sort_order", default: 0
    t.bigint "scoring_rule_id"
    t.index ["flight_id"], name: "index_payouts_on_flight_id"
    t.index ["scoring_rule_id"], name: "index_payouts_on_scoring_rule_id"
    t.index ["sort_order"], name: "index_payouts_on_sort_order"
  end

  create_table "scorecards", force: :cascade do |t|
    t.bigint "golf_outing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_confirmed", default: false
    t.bigint "designated_editor_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_scorecards_on_deleted_at"
    t.index ["golf_outing_id"], name: "index_scorecards_on_golf_outing_id"
  end

  create_table "scores", force: :cascade do |t|
    t.bigint "scorecard_id"
    t.bigint "course_hole_id"
    t.integer "strokes", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sort_order", default: 0
    t.boolean "has_notified", default: false
    t.datetime "deleted_at"
    t.integer "net_strokes", default: 0
    t.index ["course_hole_id"], name: "index_scores_on_course_hole_id"
    t.index ["deleted_at"], name: "index_scores_on_deleted_at"
    t.index ["scorecard_id"], name: "index_scores_on_scorecard_id"
    t.index ["sort_order"], name: "index_scores_on_sort_order"
  end

  create_table "scoring_rule_course_holes", force: :cascade do |t|
    t.bigint "course_hole_id"
    t.bigint "scoring_rule_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_hole_id", "scoring_rule_id"], name: "scoring_holes_index"
    t.index ["course_hole_id"], name: "index_scoring_rule_course_holes_on_course_hole_id"
    t.index ["scoring_rule_id"], name: "index_scoring_rule_course_holes_on_scoring_rule_id"
  end

  create_table "scoring_rule_participations", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "scoring_rule_id"
    t.decimal "dues_paid", default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "disqualified", default: false
    t.index ["scoring_rule_id"], name: "index_scoring_rule_participations_on_scoring_rule_id"
    t.index ["user_id", "scoring_rule_id"], name: "scoring_participations_index"
    t.index ["user_id"], name: "index_scoring_rule_participations_on_user_id"
  end

  create_table "scoring_rules", force: :cascade do |t|
    t.string "type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tournament_day_id"
    t.boolean "is_opt_in", default: false
    t.decimal "dues_amount", default: "0.0"
    t.integer "scoring_rule_course_holes_count", default: 0
    t.boolean "primary_rule", default: false
    t.string "custom_name"
    t.boolean "base_stroke_play", default: false
    t.index ["primary_rule"], name: "index_scoring_rules_on_primary_rule"
    t.index ["tournament_day_id"], name: "index_scoring_rules_on_tournament_day_id"
    t.index ["type"], name: "index_scoring_rules_on_type"
    t.index ["updated_at"], name: "index_scoring_rules_on_updated_at"
  end

  create_table "scoring_rules_users", id: false, force: :cascade do |t|
    t.bigint "scoring_rule_id", null: false
    t.bigint "user_id", null: false
    t.index ["scoring_rule_id", "user_id"], name: "index_scoring_rules_users_on_scoring_rule_id_and_user_id"
  end

  create_table "subscription_credits", force: :cascade do |t|
    t.decimal "amount"
    t.integer "golfer_count"
    t.string "transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "league_season_id"
  end

  create_table "tournament_day_results", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "user_primary_scorecard_id"
    t.bigint "flight_id"
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
    t.integer "rank", default: 0
    t.string "name"
    t.boolean "aggregated_result", default: false
    t.integer "sort_rank"
    t.bigint "scoring_rule_id"
    t.bigint "league_season_team_id"
    t.integer "back_nine_gross_score", default: 0
    t.index ["aggregated_result"], name: "index_tournament_day_results_on_aggregated_result"
    t.index ["flight_id"], name: "index_tournament_day_results_on_flight_id"
    t.index ["league_season_team_id"], name: "index_tournament_day_results_on_league_season_team_id"
    t.index ["scoring_rule_id"], name: "index_tournament_day_results_on_scoring_rule_id"
    t.index ["sort_rank"], name: "index_tournament_day_results_on_sort_rank"
    t.index ["updated_at"], name: "index_tournament_day_results_on_updated_at"
    t.index ["user_id", "scoring_rule_id"], name: "index_tournament_day_results_on_user_id_and_scoring_rule_id"
    t.index ["user_id"], name: "index_tournament_day_results_on_user_id"
    t.index ["user_primary_scorecard_id"], name: "index_tournament_day_results_on_user_primary_scorecard_id"
  end

  create_table "tournament_days", force: :cascade do |t|
    t.bigint "tournament_id"
    t.bigint "course_id"
    t.integer "game_type_id"
    t.datetime "tournament_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin_has_customized_teams", default: false
    t.boolean "data_was_imported", default: false
    t.boolean "enter_scores_until_finalized", default: false
    t.index ["course_id"], name: "index_tournament_days_on_course_id"
    t.index ["tournament_at"], name: "index_tournament_days_on_tournament_at"
    t.index ["tournament_id"], name: "index_tournament_days_on_tournament_id"
    t.index ["updated_at"], name: "index_tournament_days_on_updated_at"
  end

  create_table "tournament_groups", force: :cascade do |t|
    t.datetime "tee_time_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "max_number_of_players", default: 4
    t.bigint "tournament_day_id"
    t.index ["tournament_day_id"], name: "index_tournament_groups_on_tournament_day_id"
  end

  create_table "tournaments", force: :cascade do |t|
    t.bigint "league_id"
    t.string "name"
    t.datetime "signup_opens_at"
    t.datetime "signup_closes_at"
    t.integer "max_players"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_finalized", default: false
    t.boolean "show_players_tee_times", default: false
    t.integer "auto_schedule_for_multi_day", default: 1
    t.boolean "allow_credit_card_payment", default: true
    t.integer "tournament_days_count", default: 0
    t.datetime "tournament_starts_at"
    t.index ["league_id"], name: "index_tournaments_on_league_id"
    t.index ["updated_at"], name: "index_tournaments_on_updated_at"
  end

  create_table "users", force: :cascade do |t|
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
    t.bigint "parent_id"
    t.boolean "is_blocked", default: false
    t.datetime "deleted_at"
    t.string "country"
    t.boolean "supereditor", default: false
    t.boolean "beta_server", default: false
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
