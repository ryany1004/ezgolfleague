require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "User" do
  let (:generic_user) { build(:user, first_name: "Hunter", last_name: "Hillegas") }

  it ".complete_name" do
    expect(generic_user.complete_name).to eq("Hunter Hillegas")
  end

  it ".complete_name_with_email" do
    user = build(:user, first_name: "Hunter", last_name: "Hillegas", email: "test@test.com")

    expect(user.complete_name_with_email).to eq("Hunter Hillegas (test@test.com)")
  end

  it ".short_name" do
    expect(generic_user.short_name).to eq("Hunter H.")
  end

  it "is_any_league_admin?" do
    user = create(:user)
    league = create(:league)

    user.leagues << league

    membership = user.league_memberships.first
    membership.is_admin = true
    membership.save

    user.is_any_league_admin?

    expect(user.is_any_league_admin?).to eq(true)
  end

  it "is_member_of_league?" do
    user = create(:user)
    league = create(:league)

    user.leagues << league

    expect(user.is_member_of_league?(league)).to eq(true)
  end

  it ".scoring_group_name_for_league_season"

  it ".can_edit_user?"

  it ".impersonatable_users"

  it ".requires_additional_profile_data?" do
    user = build(:user, first_name: "Hunter", last_name: "Hillegas", phone_number: nil)

    expect(user.requires_additional_profile_data?).to eq(true)
  end

  it ".has_all_exempt_leagues?"

  it ".ios_devices" do 
    user = create(:user_with_mobile_devices, mobile_device_type: "iphone")

    expect(user.ios_devices.count).to eq(1)
  end
end

describe "User - Handicaps" do
  let (:generic_user) { build(:user, handicap_index: 12) }

  it ".course_handicap_for_golf_outing"

  it ".index_derived_handicap"

  it ".standard_handicap" do
    course = create(:course_with_eighteen_holes)

    standard_handicap = generic_user.standard_handicap(course, course.course_tee_boxes.first)

    expect(standard_handicap).to eq(14)
  end

  it ".nine_hole_handicap" do
    course = create(:course_with_nine_holes)

    nine_hole_handicap = generic_user.nine_hole_handicap(course, course.course_tee_boxes.first)

    expect(nine_hole_handicap).to eq(7)
  end
end