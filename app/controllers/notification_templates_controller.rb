class NotificationTemplatesController < BaseController
  before_action :fetch_notification_template, :only => [:edit, :update, :destroy]
  before_action :fetch_other_details

  def index
    if current_user.is_super_user?
      @notification_templates = NotificationTemplate.order("deliver_at DESC").page params[:page]

      @page_title = "All Notifications"
    else
      leagues = current_user.leagues_admin
      league_ids = leagues.map {|n| n.id}

      @notification_templates = NotificationTemplate.where("league_id IN (?)", league_ids).order("deliver_at DESC").page params[:page]

      @page_title = "League Notifications"
    end
  end

  def new
    @notification_template = NotificationTemplate.new
    @notification_template.deliver_at = DateTime.now + 5.minutes
  end

  def create
    @notification_template = NotificationTemplate.new(notification_template_params)

    if @notification_template.league.blank?
      @notification_template.league = @notification_template.tournament.league
    end

    if @notification_template.save
      SendNotificationsJob.perform_later

      redirect_to notification_templates_path, :flash => { :success => "The notification was successfully created." }
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @notification_template.update(notification_template_params)
      SendNotificationsJob.perform_later

      redirect_to notification_templates_path, :flash => { :success => "The notification was successfully updated." }
    else
      render :edit
    end
  end

  def duplicate_template
    template_to_copy = NotificationTemplate.find(params[:notification_template_id])

    new_copy = NotificationTemplate.create(title: template_to_copy.title, body: template_to_copy.body, deliver_at: DateTime.now + 1.day, league: template_to_copy.league, tournament: template_to_copy.tournament)

    redirect_to edit_notification_template_path(new_copy)
  end

  def destroy
    @notification_template.destroy

    redirect_to notification_templates_path, :flash => { :success => "The notification was successfully deleted." }
  end

  private

  def notification_template_params
    params.require(:notification_template).permit(:title, :body, :deliver_at, :tournament_id, :league_id)
  end

  def fetch_notification_template
    #TODO: Update for secure fetching
    @notification_template = NotificationTemplate.find(params[:id])
  end

  def fetch_other_details
    if current_user.is_super_user?
      @leagues = League.all.order("name")
    else
      @leagues = current_user.leagues
    end

    @tournaments = Tournament.all_upcoming(@leagues)
  end

end
