class BaseController < ActionController::Base
  layout 'application'

  force_ssl if: :ssl_configured?

  def ssl_configured?
    !Rails.env.development?
  end

  before_action :authenticate_user!
  before_action :forward_to_beta
  around_action :user_time_zone, if: :current_user

  def forward_to_beta
    return if Rails.env.development? || Rails.env.staging?
    return if current_user.blank?

    if params[:set_env] == 'production'
      current_user.update(beta_server: false)
    elsif current_user.beta_server && !/^beta/.match(request.host)
      redirect_to("#{request.protocol}beta.ezgolfleague.com#{request.original_fullpath}", status: 302)
    end
  end

  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end

  def view_tournament_from_user_for_tournament_id(tournament_id)
    if current_user.is_super_user?
      Tournament.find_by(id: tournament_id)
    else
      current_user.tournaments.find_by(id: tournament_id)
    end
  end

  def fetch_tournament_from_user_for_tournament_id(tournament_id)
    if current_user.is_super_user?
      Tournament.find_by(id: tournament_id)
    else
      current_user.tournaments_admin.find_by(id: tournament_id)
    end
  end

  def fetch_scorecard(scorecard_id)
    scorecard = Scorecard.find(scorecard_id)

    if current_user.is_super_user? || scorecard.user_can_edit?(current_user)
      scorecard
    else
      nil
    end
  end

  def view_league_from_user_for_league_id(league_id)
    if current_user.is_super_user?
      League.find_by(id: league_id)
    else
      current_user.leagues.find_by(id: league_id)
    end
  end

  def league_from_user_for_league_id(league_id)
    if current_user.is_super_user?
      League.find_by(id: league_id)
    else
      current_user.leagues_admin.find_by(id: league_id)
    end
  end

  impersonates :user
end
