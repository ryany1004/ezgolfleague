class Api::V1::TournamentsController < Api::V1::ApiBaseController
  before_filter :protect_with_token
  
  respond_to :json
  
  def index    
    todays_tournaments = Tournament.all_today([@current_user.selected_league])
    upcoming_tournaments = Tournament.all_upcoming([@current_user.selected_league], nil)
    past_tournaments = Tournament.all_past([@current_user.selected_league], nil)
    
    all_tournaments = todays_tournaments + upcoming_tournaments + past_tournaments
    
    respond_with(all_tournaments) do |format|
      format.json { render :json => all_tournaments }
    end
  end
  
end