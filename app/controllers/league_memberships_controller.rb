class LeagueMembershipsController < BaseController
  before_action :fetch_league
  before_action :fetch_users
  before_action :fetch_membership, only: [:edit, :update, :destroy]

  def index
    @league_memberships = @league.league_memberships.includes(:user).order('users.last_name').page params[:page]

    @page_title = 'League Memberships'
  end

  def print
    @league_memberships = @league.league_memberships.includes(:user).order('users.last_name')

    render layout: false
  end

  def new
    @league_membership = LeagueMembership.new
  end

  def create
    @league_membership = LeagueMembership.new(membership_params)

    @league_membership.state = MembershipStates::ACTIVE_FOR_BILLING
    @league_membership.league = @league

    if @league_membership.save
      redirect_to league_league_memberships_path(@league), flash:
      { success: 'The membership was successfully created.' }
    else
      render :new
    end
  end

  def edit; end

  def update
    if @league_membership.update(membership_params)
      if @league_membership.user.ghin_number.present?
        Rails.logger.info { "Updating GHIN for #{@league_membership.user}" }

        GhinUpdateJob.perform_later([@league_membership.user.id])
      end

      redirect_to league_league_memberships_path(@league), flash: { success: 'The membership was successfully updated.' }
    else
      render :edit
    end
  end

  def destroy
    @league_membership.destroy

    redirect_to league_league_memberships_path(@league), flash:
    { success: 'The membership was successfully deleted.' }
  end

  def update_handicaps
    params[:handicaps].keys.each do |membership_id|
      league_membership = @league.league_memberships.find(membership_id)
      next if league_membership.blank?

      league_membership.update(course_handicap: params[:handicaps][membership_id]['course_handicap'])
      league_membership.user.update(handicap_index: params[:handicaps][membership_id]['handicap_index'])
    end

    redirect_to league_league_memberships_path(@league), flash: { success: 'The handicaps were successfully updated.' }
  end

  private

  def membership_params
    params.require(:league_membership).permit(:user, :user_id, :league, :league_id, :is_admin, :league_dues_discount)
  end

  def fetch_membership
    @league_membership = @league.league_memberships.find(params[:id])
  end

  def fetch_league
    @league = league_from_user_for_league_id(params[:league_id])
  end

  def fetch_users
    if @league.users.count.positive?
      existing_user_ids = @league&.users&.map { |n| n.id }

      @users = User.where('id NOT IN (?)', existing_user_ids).order(:last_name).order(:first_name).order(created_at: :desc)
    else
      @users = User.all.order(:last_name).order(:first_name).order(created_at: :desc)
    end

    @users = User.where(id: @league_membership.user.id) if @users.count.zero? && @league_membership.present?
  end
end
