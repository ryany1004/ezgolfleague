class Play::DashboardController < Play::BaseController
  layout "golfer"

  def index
    if current_user.selected_league.blank? && current_user.impersonatable_users.blank?
      redirect_to leagues_play_registrations_path, :flash => { :success => "Please create or join a league to continue." }
    elsif current_user.selected_league.blank? && !current_user.impersonatable_users.blank?
      render 'select_user'
    else
      @page_title = "My Dashboard"

      active_season = current_user.active_league_season
      if session[:selected_season_id].blank?
        @league_season = active_season
      else
        @league_season = current_user.selected_league.league_seasons.where(id: session[:selected_season_id]).first
      end

      @has_unpaid_upcoming_tournaments = false

      if @league_season == active_season
        @todays_tournaments = Tournament.all_today([current_user.selected_league])

        @todays_tournaments.each do |t|
          @has_unpaid_upcoming_tournaments = false if !t.user_has_paid?(current_user)
        end
      end

      unless @league_season.blank?
        @upcoming_tournaments = Tournament.all_upcoming([current_user.selected_league], @league_season.ends_at).select {|t| t.all_days_are_playable? }.to_a
        @past_tournaments = Tournament.past_for_league_season(@league_season).select {|t| t.all_days_are_playable? }.to_a

        @rankings = Rails.cache.fetch(@league_season.rankings_cache_key, expires_in: 24.hours, race_condition_ttl: 10) do
          current_user.selected_league.ranked_users_for_year(@league_season.starts_at, @league_season.ends_at)
        end
      else
        @upcoming_tournaments = Tournament.all_upcoming([current_user.selected_league], nil).select {|t| t.all_days_are_playable? }.to_a
        @past_tournaments = Tournament.all_past([current_user.selected_league], nil).select {|t| t.all_days_are_playable? }.to_a

        @rankings = current_user.selected_league.ranked_users_for_year(nil, nil)
      end
    end
  end

  def switch_seasons
    session[:selected_season_id] = params[:season_id]

    redirect_to play_dashboard_index_path
  end

  def switch_users
    switch_to_user = User.find(params[:dashboard_id])

    impersonate_user(switch_to_user) if current_user.impersonatable_users.include? switch_to_user

    redirect_to play_dashboard_index_path
  end

  def switch_leagues
    league = self.league_from_user_for_league_id(params[:league_id])
    current_user.current_league = league
    current_user.save

    session[:selected_season_id] = nil

    redirect_to play_dashboard_index_path
  end

end
