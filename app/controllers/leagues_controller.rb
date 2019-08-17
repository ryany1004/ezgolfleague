class LeaguesController < BaseController
  before_action :fetch_league, only: [:edit, :update, :destroy]

  def index
    if current_user.is_super_user?
      @leagues = League.order(:name).page params[:page]

      @page_title = "All Leagues"
    else
      @leagues = current_user.leagues_admin.order(:name).page params[:page]

      @page_title = "My Leagues"
    end

    unless params[:search].blank?
      search_string = "%#{params[:search].downcase}%"

      @leagues = @leagues.where("lower(name) LIKE ?", search_string)
    end
  end

  def new
    @league = League.new
  end

  def create
    @league = League.new(league_params)

    if @league.save
      redirect_to leagues_path, flash: { success: "The league was successfully created." }
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @league.update(league_params)
      redirect_to leagues_path, flash: { success: "The league was successfully updated." }
    else
      render :edit
    end
  end

  def destroy
    @league.destroy

    redirect_to leagues_path, flash: { success: "The league was successfully deleted." }
  end

  def update_from_ghin
    @league = League.find(params[:league_id])

    users = @league.users
                   .where('ghin_number IS NOT NULL')
                   .where("ghin_number != ''")
                   .order(:ghin_updated_at)

    GhinUpdateJob.perform_later(users.pluck(:id))

    redirect_to leagues_path, flash: { success: "League members will be updated by GHIN." }
  end

  def update_calculated_handicaps
    @league = League.find(params[:league_id])

    HandicapCalculationJob.perform_later(@league)

    redirect_to leagues_path, flash: { success: "League members will have handicaps updated from past rounds and changes applied to future tournaments." }
  end

  def update_league_standings
    @league = League.find(params[:league_id])

    @league.league_seasons.order('created_at DESC').each do |s|
      RankLeagueSeasonJob.perform_later(s, true)
    end

    redirect_to leagues_path, flash: { success: 'All seasons have been queued for standings re-calculation.' }
  end

  def write_member_email
    @league = League.find(params[:league_id])
  end

  def send_member_email
    @league = League.find(params[:league_id])

    email_addresses = @league.users.pluck(:email)
    RecordEventJob.perform_later(email_addresses, "A league message was sent", { league_name: @league.name, message_subject: params[:league_send_member_email][:subject], message_contents: params[:league_send_member_email][:contents] })

    redirect_to leagues_path, flash: { success: "The message was sent." }
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
    if params[:id].blank?
      league_id = params[:league_id]
    else
      league_id = params[:id]
    end

    if current_user.is_super_user
      @league = League.find(league_id)
    else
      @league = current_user.leagues_admin.find(league_id)
    end
  end

end
