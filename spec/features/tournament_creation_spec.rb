require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Creating a tournament" do
  before(:each) do
    course = FactoryGirl.create(:course_with_holes)

    user = login_user
    login_as(user, scope: :user)

    visit league_admin_root_path

    click_on("Create Tournament")

    fill_in("Name", with: "Test Tournament")
    select(League.first.name, from: "tournament_league_id")
    fill_in("tournament_dues_amount", with: "100")
    fill_in("tournament_signup_opens_at", with: (DateTime.now + 1.day).strftime("%m/%d/%Y %I:%M %p"))
    fill_in("tournament_signup_closes_at", with: (DateTime.now + 5.days).strftime("%m/%d/%Y %I:%M %p"))
    fill_in("tournament_max_players", with: "100")
    click_on("Save & Continue")

    click_on("add_button_1")

    select(Course.first.name, from: "tournament_day_course_id")
    fill_in("tournament_day_tournament_at", with: (DateTime.now + 2.days).strftime("%m/%d/%Y %I:%M %p"))
    click_on("Save & Continue")

    click_on("Save & Continue")

    #game type
    select("Individual Stroke Play", from: "tournament_tournament_days_attributes_0_game_type_id")
    click_on("Save & Continue")

    #tee times
    fill_in("tournament_group_separation_interval", with: 8)
    fill_in("tournament_group_max_number_of_players", with: 4)
    fill_in("tournament_group_number_of_tee_times_to_create", with: 4)
    click_on("Save Tee Time Batch")

    #flights
    click_on("add_flight_1")
    fill_in("flight_upper_bound", with: "1000")
    select(course.course_tee_boxes.first.name, from: "flight_course_tee_box_id")
    click_on("Save & Continue")

    #payouts
    click_on("payout_button_1")
    select(Flight.first.flight_number, from: "payout_flight_id")
    fill_in("payout_amount", with: "100")
    fill_in("payout_points", with: "10")
    click_on("Save & Continue")

    #contests
    click_on("contest_button_1")
    fill_in("contest_name", with: "Custom Overall Winner")
    choose("contest_contest_type_0")
    click_on("Save & Continue")

    #notifications
    click_on("notification_button_1")
    fill_in("notification_template_title", with: "Test Notification")
    fill_in("notification_template_body", with: "Test Body")
    select("On Finalization", from: "notification_template_tournament_notification_action")
    click_on("Save & Complete Tournament Setup")

    #players
    visit league_tournament_day_players_path(League.first, Tournament.first, TournamentDay.first)
    select(user.complete_name, from: "player_signups[member_id[1][0]]")
    click_on("Save Your Changes & Register Players")

    visit league_admin_root_path
  end

  it "Create a stroke play tournament" do
    page.has_content?('Test Tournament')
  end
end
