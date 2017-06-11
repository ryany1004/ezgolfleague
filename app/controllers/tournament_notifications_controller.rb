class TournamentNotificationsController < BaseController
  before_action :fetch_notification_template, :only => [:edit, :update, :destroy]
  before_action :fetch_other_details
  before_action :set_stage

  def index
    @notification_templates = @tournament.notification_templates.page
  end

  def new
    @notification_template = NotificationTemplate.new
    @notification_template.deliver_at = DateTime.now - 5.minutes #always in the past
    @notification_template.tournament = @tournament
    @notification_template.league = @tournament.league
  end

  def create
    @notification_template = NotificationTemplate.new(notification_template_params)

    if @notification_template.save
      Delayed::Job.enqueue SendNotificationsJob.new()

      if params[:commit] == "Save & Complete Tournament Setup"
        redirect_to league_tournaments_path(current_user.selected_league), :flash => { :success => "The notification was successfully created." }
      else
        redirect_to league_tournament_tournament_notifications_path, :flash => { :success => "The notification was successfully created." }
      end
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @notification_template.update(notification_template_params)
      Delayed::Job.enqueue SendNotificationsJob.new()

      redirect_to league_tournament_tournament_notifications_path, :flash => { :success => "The notification was successfully updated." }
    else
      render :edit
    end
  end

  def destroy
    @notification_template.destroy

    redirect_to league_tournament_tournament_notifications_path, :flash => { :success => "The notification was successfully deleted." }
  end

  private

  def notification_template_params
    params.require(:notification_template).permit(:title, :body, :deliver_at, :tournament_notification_action, :tournament_id, :league_id)
  end

  def fetch_notification_template
    @notification_template = NotificationTemplate.find(params[:id])
  end

  def set_stage
    if params[:tournament_day].blank?
      if @tournament.tournament_days.count > 1
        @stage_name = "notifications#{@tournament.first_day.id}"
      else
        @stage_name = "notifications"
      end
    else
      @stage_name = "notifications#{@tournament_day.id}"
    end
  end

  def fetch_other_details
    @tournament = Tournament.find(params[:tournament_id])
    @tournament_actions = ["On Finalization", "To Unregistered Members 1 Day Before Registration Closes"]
  end
end
