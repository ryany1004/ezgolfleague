module FindPlayers
  extend ActiveSupport::Concern
  
  def flight_for_player(user)        
    self.flights.each do |f|
      return f if f.users.include? user
    end
  
    return nil
  end

  def golfer_team_for_player(user)
    self.golfer_teams.each do |t|
      return t if t.users.include? user
    end
  
    return nil
  end

  def tournament_group_for_player(user)
    self.tournament_groups.each do |group|
      group.teams.each do |team|
        team.golf_outings.each do |outing|
          return group if outing.user == user
        end
      end
    end
  
    return nil
  end

  def golf_outing_for_player(user)
    self.tournament_groups.each do |group|
      group.teams.each do |team|
        team.golf_outings.each do |outing|
          return outing if outing.user == user
        end
      end
    end
  
    return nil
  end
  
end