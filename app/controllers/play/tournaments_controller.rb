class Play::TournamentsController < Play::BaseController
  layout 'golfer'

  before_action :fetch_tournament, except: [:show]

  def show
    tournament = view_tournament_from_user_for_tournament_id(params[:id])
    redirect_to root_path if tournament.blank?

    if tournament.tournament_days.count == 1
      tournament_day = tournament.tournament_days.first
    else
      tournament_day = tournament.tournament_days.find_by(id: params[:tournament_day])
      tournament_day = tournament.tournament_days.last if tournament_day.blank?
    end

    if tournament_day.present?
      day_flights = fetch_flights_with_rankings(tournament_day)
      combined_flights = fetch_combined_flights_with_rankings(tournament_day, day_flights)
    else
      day_flights = nil
      combined_flights = fetch_combined_flights_with_rankings(tournament.tournament_days.last, fetch_flights_with_rankings(tournament.tournament_days.last))
    end

    show_combined = params[:combined].present? ? true : false

    @tournament_presenter = TournamentPresenter.new({ show_combined: show_combined,
                                                      tournament: tournament,
                                                      tournament_day: tournament_day,
                                                      user: current_user,
                                                      day_flights: day_flights,
                                                      combined_flights: combined_flights })

    @page_title = tournament.name
  end

  def leaderboard
    @tournament = self.view_tournament_from_user_for_tournament_id(params[:tournament_id])
    @tournament_day = @tournament.tournament_days.find(params[:day])
    @user_scorecard = @tournament_day.primary_scorecard_for_user(current_user)

    @day_flights_with_rankings = self.fetch_flights_with_rankings(@tournament_day)
    @combined_flights_with_rankings = self.fetch_combined_flights_with_rankings(@tournament_day, @day_flights_with_rankings)

    @page_title = "#{@tournament.name} Leaderboard"
  end

  def confirm
    @tournament = self.view_tournament_from_user_for_tournament_id(params[:tournament_id])
    @tournament.tournament_days.each do |td|
      outing = td.golf_outing_for_player(current_user)

      unless outing.blank?
        outing.is_confirmed = true
        outing.save
      end
    end

    redirect_to play_dashboard_index_path, flash: { success: "You are confirmed for the tournament." }
  end

  def signup
    if @tournament.show_players_tee_times == true
      render "signup_with_times"
    else
      render "signup_without_times"
    end
  end

  def complete_signup
    if @tournament.includes_player?(current_user)
      redirect_to play_tournament_signup_path(@tournament), flash: { error: "You are already registered for this tournament. Remove your existing registration and try again." }
    else
      tournament_group = @tournament.first_day.tournament_groups.find(params[:group_id])

      paying_now = false
      paying_now = true if params[:pay_now].present?

      @tournament.first_day.add_player_to_group(tournament_group: tournament_group, user: current_user, paying_with_credit_card: paying_now, registered_by: current_user.complete_name)

      # other associated signup
      if params[:tournament].present? && params[:tournament][:another_member_id].present?
        other_user = User.find(params[:tournament][:another_member_id])

        @tournament.first_day.add_player_to_group(tournament_group: tournament_group, user: other_user, paying_with_credit_card: false, confirmed: false, registered_by: current_user.complete_name)
      end

      # optional game types
      if params[:tournament].present? && params[:tournament][:optional_game_types].present? #TODO: Fix this total hack
        params[:tournament][:optional_game_types].each do |game_type_id|
        	next if game_type_id.blank?

	        scoring_rule = ScoringRule.find(game_type_id)
	        scoring_rule.users << current_user
        end
      end

      # payment
      if paying_now == true
        redirect_to new_play_payment_path(payment_type: "tournament_dues", tournament_id: @tournament.id)
      else
        TournamentMailer.tournament_player_paying_later(current_user, @tournament).deliver_later

        redirect_to play_dashboard_index_path, flash: { success: "You are registered for the tournament." }
      end
    end
  end

  def remove_signup
    @tournament.tournament_days.each do |day|
      day.tournament_groups.each do |tg|
        tg.golf_outings.each do |outing|
          day.remove_player_from_group(tournament_group: tg, user: current_user) if outing.user == current_user
        end
      end
    end

    TournamentMailer.tournament_player_cancelled(current_user, @tournament).deliver_later

    redirect_to play_dashboard_index_path, flash: { success: "Your registration has been canceled." }
  end

  def fetch_flights_with_rankings(tournament_day)
    tournament_day.primary_scoring_rule_flights_with_rankings
  end

  def fetch_combined_flights_with_rankings(tournament_day, _)
    FetchingTools::LeaderboardFetching.flights_with_rankings_could_be_combined(tournament_day)
  end

  private

  def fetch_tournament
    @tournament = view_tournament_from_user_for_tournament_id(params[:tournament_id])
  end
end
