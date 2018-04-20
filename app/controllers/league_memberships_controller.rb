class LeagueMembershipsController < BaseController
  before_action :fetch_league
  before_action :fetch_users
  before_action :fetch_membership, :only => [:edit, :update, :destroy]

  def index
    @league_memberships = @league.league_memberships.includes(:user).order("users.last_name").page params[:page]

    @page_title = "League Memberships"
  end

  def print
    @league_memberships = @league.league_memberships.includes(:user).order("users.last_name")

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
      redirect_to league_league_memberships_path(@league), :flash => { :success => "The membership was successfully created." }
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @league_membership.update(membership_params)
      unless @league_membership.user.ghin_number.blank?
        Rails.logger.info { "Updating GHIN for #{@league_membership.user}" }

        GhinUpdateJob.perform_later([@league_membership.user.id])
      end

      redirect_to league_league_memberships_path(@league), :flash => { :success => "The membership was successfully updated." }
    else
      render :edit
    end
  end

  def destroy
    @league_membership.destroy

    redirect_to league_league_memberships_path(@league), :flash => { :success => "The membership was successfully deleted." }
  end

  private

  def membership_params
    params.require(:league_membership).permit(:user, :user_id, :league, :is_admin, :league_dues_discount)
  end

  def fetch_membership
    @league_membership = @league.league_memberships.find(params[:id])
  end

  def fetch_league
    @league = self.league_from_user_for_league_id(params[:league_id])
  end

  def fetch_users
    if @league.users.count > 0
      existing_user_ids = @league.users.map { |n| n.id }

      @users = User.where("id NOT IN (?)", existing_user_ids).order("last_name").order("first_name").order("created_at DESC")
    else
      @users = User.all.order("last_name").order("first_name").order("created_at DESC")
    end

    @users = User.where(id: @league_membership.user.id) if @users.count == 0 && @league_membership.blank? == false
  end

end
