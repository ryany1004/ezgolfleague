require 'rails_helper'

#ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

describe "Tournament Day" do
  let (:generic_user) { build(:user) }

  it "#server_id" do 
    expect(generic_user).to respond_to(:server_id) 
  end

  it "#is_first_day?"

  it "#pretty_day"

  it "#paid_contest"

  it "#registered_user_ids"

  it "#paid_user_ids"

  it "#superuser_user_ids"

  it "#league_admin_user_ids"
end
