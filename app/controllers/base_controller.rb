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

  def view_tournament_from_user_for_tournament_id(tournament_id)
    if current_user.is_super_user?
      @tournament = Tournament.find(tournament_id)
    else
      @tournament = current_user.tournaments.where(id: tournament_id).first
    end

    return @tournament
  end

  def fetch_tournament_from_user_for_tournament_id(tournament_id)
    if current_user.is_super_user?
      @tournament = Tournament.find(tournament_id)
    else
      @tournament = current_user.tournaments_admin.where(id: tournament_id).first
    end

    return @tournament
  end

  def view_league_from_user_for_league_id(league_id)
    if current_user.is_super_user?
      @league = League.find(league_id)
    else
      @league = current_user.leagues.where(id: league_id).first
    end

    return @league
  end

  def league_from_user_for_league_id(league_id)
    if current_user.is_super_user?
      @league = League.find(league_id)
    else
      @league = current_user.leagues_admin.where(id: league_id).first
    end

    return @league
  end

  impersonates :user
end
