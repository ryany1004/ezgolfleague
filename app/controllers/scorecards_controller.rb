class ScorecardsController < BaseController
  before_action :fetch_all_params, :only => [:edit]
  before_action :fetch_scorecard, :only => [:show, :update]
  
  def index
    @tournament = Tournament.find(params[:tournament_id])

    if params[:tournament_day].blank?
      @tournament_day = @tournament.first_day
    else
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day])
    end
    
    @page_title = "Scorecards"
    
    @eager_groups = TournamentGroup.includes(golf_outings: [{scorecard: :scores}, :user]).where(tournament_day: @tournament_day)

    #TODO: Fetch scorecards and group into groups, vs other way around
    #@scorecards = Scorecard.where()
  end
  
  def show
  end
  
  def edit
  end
  
  def update
    scores_to_update = Hash.new
    
    params[:scorecard][:scores_attributes].keys.each do |key|
      score_id = params[:scorecard][:scores_attributes][key]["id"]
      strokes = params[:scorecard][:scores_attributes][key]["strokes"]
      
      scores_to_update[score_id] = {:strokes => strokes}
    end

    logger.debug { "Sending: #{scores_to_update}" }

    UpdatingTools::ScorecardUpdating.update_scorecards_for_scores(scores_to_update, @scorecard, @other_scorecards)

    redirect_to scorecards_path(tournament_id: @tournament), :flash => { :success => "The scorecard was successfully updated." }
  end
 
  def print
    @tournament = Tournament.find(params[:tournament_id])

    if params[:tournament_day].blank?
      @tournament_day = @tournament.first_day
    else
      @tournament_day = @tournament.tournament_days.find(params[:tournament_day])
    end
    
    @print_cards = []
    
    @tournament.players_for_day(@tournament_day).each do |player|
      primary_scorecard = @tournament_day.primary_scorecard_for_user(player)
      other_scorecards = @tournament_day.related_scorecards_for_user(player, true)
      
      if other_scorecards.count < 4
        number_to_create = (4 - other_scorecards.count) - 1
        
        number_to_create.times do 
          extra_scorecard = GameTypes::EmptyLineScorecard.new
          extra_scorecard.scores_for_course_holes(@tournament_day.course_holes)
          
          other_scorecards << extra_scorecard
        end
      end
      
      scorecard_presenter = Presenters::ScorecardPresenter.new({primary_scorecard: primary_scorecard, secondary_scorecards: other_scorecards})
      
      @print_cards << {p: scorecard_presenter} if !self.printable_cards_includes_player?(@print_cards, player)
    end
      
    render layout: false
  end
 
  def printable_cards_includes_player?(printable_cards, player)
    printable_cards.each do |card|
      return true if card[:p].primary_scorecard.golf_outing.user == player
      
      card[:p].secondary_scorecards.each do |other|
        unless other.golf_outing.blank?
          return true if other.golf_outing.user == player
        end
      end
    end
    
    return false
  end
 
  private
  
  def scorecard_params
    params.require(:scorecard).permit(scores_attributes: [:id, :strokes])
  end
  
  def fetch_all_params
    @scorecard = Scorecard.find(params[:id])
    @player = @scorecard.golf_outing.user
    @tournament_day = @scorecard.golf_outing.tournament_group.tournament_day
    @tournament = @tournament_day.tournament
    @handicap_allowance = @tournament_day.handicap_allowance(@scorecard.golf_outing.user)
  end
  
  def fetch_scorecard
    scorecard_info = FetchingTools::ScorecardFetching.fetch_scorecards_and_related(params[:id])
    
    @tournament_day = scorecard_info[:tournament_day]
    @tournament = scorecard_info[:tournament]
    
    scorecard = scorecard_info[:scorecard]
    other_scorecards = scorecard_info[:other_scorecards]
    
    @scorecard_presenter = Presenters::ScorecardPresenter.new({primary_scorecard: @scorecard, secondary_scorecards: @other_scorecards})
  end
  
end
