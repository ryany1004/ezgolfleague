class BaseController < ActionController::Base
  layout "application"

  force_ssl if: :ssl_configured?

  def ssl_configured?
    !Rails.env.development?
  end

  before_action :authenticate_user!
  around_action :user_time_zone, if: :current_user

  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end

  def fetch_tournament_from_user_for_tournament_id(tournament_id)
    @tournament = current_user.tournaments_admin.where(id: tournament_id).first
    @tournament = Tournament.find(tournament_id) if @tournament.blank? && current_user.is_super_user?

    @tournament
  end

  def league_from_user_for_league_id(league_id)
    @league = current_user.leagues_admin.where(id: league_id).first
    @league = League.find(league_id) if @league.blank? && current_user.is_super_user?

    @league
  end

  impersonates :user
end
