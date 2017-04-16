class LeagueMembershipsController < BaseController
  before_action :fetch_membership, :only => [:edit, :update, :destroy]
  before_action :fetch_league
  before_action :fetch_users

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
    if membership_params[:toggle_active] == "1"
      should_make_active = true
    else
      should_make_active = false
    end

    @league_membership = LeagueMembership.new(membership_params)
    @league_membership.league = @league

    if @league_membership.save
      if should_make_active
        @league_membership.state = MembershipStates::ACTIVE_FOR_BILLING
        @league_membership.save
      end

      redirect_to league_league_memberships_path(@league), :flash => { :success => "The membership was successfully created." }
    else
      render :new
    end
  end

  def edit
  end

  def update
    if membership_params[:toggle_active] == "1"
      @league_membership.state = MembershipStates::ACTIVE_FOR_BILLING
    else
      @league_membership.state = MembershipStates::ADDED
    end

    if @league_membership.update(membership_params)
      redirect_to league_league_memberships_path(@league), :flash => { :success => "The membership was successfully updated." }
    else
      render :edit
    end
  end

  def destroy
    @league_membership.destroy

    redirect_to league_league_memberships_path(@league), :flash => { :success => "The membership was successfully deleted." }
  end

  def update_active
    @league.league_memberships.each do |m|
      m.state = MembershipStates::ADDED
      m.save
    end

    active_status = params[:is_active]
    active_status.keys.each do |membership_id|
      membership = @league.league_memberships.where(id: membership_id).first

      unless membership.blank?
        membership.state = MembershipStates::ACTIVE_FOR_BILLING
        membership.save
      end
    end

    redirect_to league_league_memberships_path(@league), :flash => { :success => "The membership was successfully updated." }
  end

  private

  def membership_params
    params.require(:league_membership).permit(:user, :user_id, :league, :is_admin, :league_dues_discount, :toggle_active)
  end

  def fetch_membership
    @league_membership = LeagueMembership.find(params[:id])
  end

  def fetch_league
    @league = League.find(params[:league_id])
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
