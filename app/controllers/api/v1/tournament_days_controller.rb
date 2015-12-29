class Api::V1::TournamentDaysController < Api::V1::ApiBaseController
  before_filter :protect_with_token
  
  respond_to :json
  
  def tournament_groups
    tournament = Tournament.find(params[:tournament_id])
    tournament_day = tournament.tournament_days.find(params[:tournament_day_id])
    
    respond_with(tournament_day.tournament_groups) do |format|
      format.json { render :json => tournament_day.tournament_groups }
    end
  end
    
end