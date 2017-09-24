class UserAccountsController < BaseController
  before_action :fetch_user_account, :only => [:edit, :update, :destroy]
  before_action :initialize_form, :only => [:new, :edit, :edit_current]

  def index
    if current_user.is_super_user?
      @user_accounts = User.order("last_name").page params[:page]
    else
      membership_ids = current_user.leagues.map { |n| n.id }
      @user_accounts = User.joins(:league_memberships).where("league_memberships.league_id IN (?)", membership_ids).order("last_name").page params[:page]
    end

    unless params[:search].blank?
      search_string = "%#{params[:search].downcase}%"

      @user_accounts = @user_accounts.where("lower(last_name) LIKE ? OR lower(first_name) LIKE ? OR lower(email) LIKE ?", search_string, search_string, search_string)
    end

    @page_title = "User Accounts"
  end

  def new
    @user_account = User.new
  end

  def create
    @user_account = User.new(user_params)

    if @user_account.should_invite == "1"
      User.invite!(user_params, current_user)

      redirect_to user_accounts_path, :flash => { :success => "The user was successfully invited." }
    else
      if @user_account.save
        Delayed::Job.enqueue GhinUpdateJob.new([@user_account]) unless @user_account.ghin_number.blank?

        redirect_to user_accounts_path, :flash => { :success => "The user was successfully created." }
      else
        initialize_form

        render :new
      end
    end
  end

  def edit
  end

  def update
    if @user_account.update(user_params)
      unless @user_account.ghin_number.blank?
        Rails.logger.info { "Updating GHIN for #{@user_account}" }

        Delayed::Job.enqueue GhinUpdateJob.new([@user_account])
      else
        Rails.logger.info { "Not Updating GHIN for #{@user_account}" }
      end

      unless @user_account.account_to_merge_to.blank?
        destination_account = User.find(@user_account.account_to_merge_to)

        @user_account.merge_into_user(destination_account)
      end

      if @user_account == current_user
        redirect_to root_path
      else
        redirect_to user_accounts_path, :flash => { :success => "The user was successfully updated." }
      end
    else
      initialize_form

      render :edit
    end
  end

  def destroy
    #remove from future tournaments
    tournaments = Tournament.all_upcoming(@user_account.leagues).each do |t|
      if t.includes_player?(@user_account)
        t.tournament_days.each do |d|
          group = d.tournament_group_for_player(@user_account)

          d.remove_player_from_group(group, @user_account, true) unless group.blank?
        end
      end
    end

    @user_account.destroy

    redirect_to user_accounts_path, :flash => { :success => "The user was successfully deleted." }
  end

  def export_users
    attributes = %w{id email first_name last_name}

    csv = nil

    CSV.generate(headers: true) do |csv|
      csv << attributes

      User.all.each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end

    send_data csv, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment; filename=users.csv" 
  end

  def impersonate
    user = User.find(params[:user_account_id])

    impersonate_user(user)

    redirect_to root_path
  end

  def stop_impersonating
    stop_impersonating_user
    redirect_to root_path
  end

  # User

  def edit_current
    @user_account = current_user
    @editing_current_user = true
  end

  # League Admin Invite

  def setup_league_admin_invite
    @user_account = User.new
    @leagues = League.all.order("name")
  end

  def send_league_admin_invite
    if self.invite_user(user_params, true)
      redirect_to user_accounts_path, :flash => { :success => "The league admin was successfully invited." }
    else
      redirect_to user_accounts_path, :flash => { :error => "There was an error inviting the league admin. Please check your information and try again." }
    end
  end

  # Golfer Invite

  def resend_league_invite
    user = User.find(params[:user_account_id])

    user.invite!(current_user)

    redirect_to user_accounts_path, :flash => { :success => "The golfer was successfully re-invited." }
  end

  def setup_golfer_invite
    @user_account = User.new

    if current_user.is_super_user?
      @leagues = League.all.order("name")
    else
      @leagues = current_user.leagues.order("name")
    end
  end

  def send_golfer_invite
    if self.invite_user(user_params, false)
      redirect_to user_accounts_path, :flash => { :success => "The golfer was successfully invited." }
    else
      redirect_to user_accounts_path, :flash => { :error => "There was an error inviting the golfer. Please check your information and try again." }
    end
  end

  def invite_user(user_params, is_admin = false)
    existing_user = User.where("email = ?", user_params[:email]).first

    if existing_user.blank?
      @user_account = User.new(user_params)
      @user_account.password = "temporary_password1234"
      @user_account.password_confirmation = "temporary_password1234"

      if @user_account.save
        @user_account.league_memberships.each do |m|
          m.state = MembershipStates::INVITED
          m.is_admin = is_admin
          m.save
        end

        user = User.invite!({:email => @user_account.email}, current_user) do |u|
          u.skip_invitation = true
        end

        user.deliver_invitation

        return true
      else
        @user_account.errors.each do |e|
          Rails.logger.debug { "#{e}" }
        end

        return false
      end
    else
      user_params[:league_ids].each do |league_id|
        unless league_id.blank?
          league = League.find(league_id)

          existing_membership = existing_user.league_memberships.where("league_id = ?", league.id)
          if existing_membership.blank?
            LeagueMembership.create(league: league, user: existing_user, is_admin: is_admin, state: MembershipStates::ADDED)
          else
            LeagueMailer.renew_dues(existing_user, league).deliver_later if league.league_seasons.last.user_has_paid?(existing_user) == false
          end
        end
      end

      return true
    end
  end

  private

  def user_params
    params.require(:user).permit!
  end

  def fetch_user_account
    @user_account = User.find(params[:id])
  end

  def initialize_form
    @us_states = US_STATES

    if current_user.is_super_user?
      @leagues = League.all.order("name")
    else
      @leagues = current_user.leagues.order("name")
    end
  end

end
