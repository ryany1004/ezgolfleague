class LeaguesController < BaseController
  before_action :fetch_league, only: [:show, :edit, :update, :destroy]

  def show
    active_season = current_user.active_league_season
    if session[:selected_season_id].blank?
      @league_season = active_season
    else
      @league_season = current_user.selected_league.league_seasons.where(id: session[:selected_season_id]).first
    end
    @rankings = @league_season.league_season_ranking_groups
  end

  def edit; end

  def update
    if @league.update(league_params)
      render :edit, flash:
      { success: 'The league was successfully updated.' }
    else
      render :edit
    end
  end

  def destroy
    @league.destroy

    redirect_to leagues_path, flash:
    { success: 'The league was successfully deleted.' }
  end

  def switch_seasons
    session[:selected_season_id] = params[:season_id]

    redirect_to league_path(params[:league_id])
  end

  def update_from_ghin
    @league = League.find(params[:league_id])

    users = @league.users.where.not(ghin_number: nil).where.not(ghin_number: '').order(:ghin_updated_at)

    GhinUpdateJob.perform_later(users.pluck(:id))

    redirect_to leagues_path, flash:
    { success: 'League members will be updated by GHIN.' }
  end

  def update_calculated_handicaps
    @league = League.find(params[:league_id])

    HandicapCalculationJob.perform_later(@league)

    redirect_to leagues_path, flash: { success: "League members will have handicaps updated from past rounds and changes applied to future tournaments." }
  end

  def update_league_standings
    @league = League.find(params[:league_id])

    @league.league_seasons.order(created_at: :desc).each do |s|
      RankLeagueSeasonJob.perform_later(s)
    end

    redirect_to leagues_path, flash:
    { success: 'All seasons have been queued for standings re-calculation.' }
  end

  def write_member_email
    @league = League.find(params[:league_id])
  end

  def send_member_email
    @league = League.find(params[:league_id])

    email_addresses = @league.users.pluck(:email)
    RecordEventJob.perform_later(email_addresses, 'A league message was sent',
                                 { league_name: @league.name,
                                   message_subject: params[:league_send_member_email][:subject],
                                   message_contents: params[:league_send_member_email][:contents] })

    redirect_to leagues_path, flash:
    { success: 'The message was sent.' }
  end

  private

  def league_params
    params.require(:league).permit(:name,
                                   :display_balances_to_players,
                                   :override_golfer_price,
                                   :allow_scoring_groups,
                                   :required_container_frame_url,
                                   :free_tournaments_remaining,
                                   :show_in_search,
                                   :league_description,
                                   :contact_name,
                                   :contact_phone,
                                   :contact_email,
                                   :location,
                                   :stripe_production_secret_key,
                                   :stripe_production_publishable_key,
                                   :stripe_test_secret_key,
                                   :stripe_test_publishable_key,
                                   :stripe_test_mode,
                                   :dues_payment_receipt_email_addresses,
                                   :apple_pay_merchant_id,
                                   :supports_apple_pay,
                                   :exempt_from_subscription,
                                   :calculate_handicaps_from_past_rounds,
                                   :number_of_rounds_to_handicap,
                                   :number_of_lowest_rounds_to_handicap,
                                   :use_equitable_stroke_control)
  end

  def fetch_league
    if current_user.is_super_user
      @league = League.find(params[:league_id] || params[:id])
    else
      @league = current_user.leagues_admin.find(params[:league_id] || params[:id])
    end
  end
end
