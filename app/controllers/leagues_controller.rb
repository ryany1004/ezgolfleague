class LeaguesController < BaseController
  before_action :fetch_league, :only => [:edit, :update, :destroy]
  
  def index
    if current_user.is_super_user?
      @leagues = League.order("name").page params[:page]
    
      @page_title = "All Leagues"
    else
      @leagues = current_user.leagues.order("name").page params[:page]
    
      @page_title = "My Leagues"
    end
  end
  
  def new
    @league = League.new
  end
  
  def create
    @league = League.new(league_params)
      
    if @league.save      
      redirect_to leagues_path, :flash => { :success => "The league was successfully created." }
    else            
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @league.update(league_params)
      redirect_to leagues_path, :flash => { :success => "The league was successfully updated." }
    else      
      render :edit
    end
  end
  
  def destroy
    @league.destroy
    
    redirect_to leagues_path, :flash => { :success => "The league was successfully deleted." }
  end
  
  def charge_league_members
    @league = League.find(params[:league_id])
    
    @league.league_memberships.each do |m|
      Payment.create(user: m.user, payment_amount: @league.dues_for_user(m.user) * -1, league: @league, payment_details: "Dues for #{@league.name}")
    end
    
    redirect_to leagues_path, :flash => { :success => "The league members were charged." }
  end
  
  def update_from_ghin
    @league = League.find(params[:league_id])
    
    @league.users.where("ghin_number IS NOT NULL").order("last_name").each do |u|
      Importers::GHINImporter.import_ghin_for_user(u)
    end
    
    redirect_to leagues_path, :flash => { :success => "League members were updated from GHIN." }
  end
  
  def write_member_email
    @league = League.find(params[:league_id])
  end
  
  def send_member_email
    @league = League.find(params[:league_id])
    
    @league.users.each do |u|
      LeagueMailer.league_message(u, params[:league_send_member_email][:subject], params[:league_send_member_email][:contents]).deliver_later
    end
    
    redirect_to leagues_path, :flash => { :success => "The message was sent." }
  end
  
  private

  def league_params
    params.require(:league).permit(:name, :dues_amount, :stripe_production_secret_key, :stripe_production_publishable_key, :stripe_test_secret_key, :stripe_test_publishable_key, :stripe_test_mode)
  end
  
  def fetch_league
    @league = League.find(params[:id])
  end
  
end
