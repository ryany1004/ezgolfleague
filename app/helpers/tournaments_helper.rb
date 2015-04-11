module TournamentsHelper
  
  def is_editable?(tournament)
    if tournament.tournament_at < DateTime.now
      return false
    else
      return true
    end
  end
  
end
