require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Scorecard" do
	let (:generic_user) { build(:user) }

  it "#server_id" do 
    expect(generic_user).to respond_to(:server_id) 
  end

  it "#set_course_handicap"

  it "#gross_score"

  it "#net_score"

  it "#front_nine_net_score"

  it "#back_nine_net_score"

  it "#flight_number"

  it "#course_handicap"

  it "#has_empty_scores?"

  it "#last_hole_played"

  it "#user_can_view?"

  it "#user_can_edit?"

  it "#is_potentially_editable?"

  it "#should_highlight?"

  it "#name"

  it "#individual_name"

  it "#can_display_handicap?"

  it "#should_subtotal?"

  it "#should_total?"

  it "#includes_extra_scoring_column?"

end