module Addable
  extend ActiveSupport::Concern

  def add_player_to_group(tournament_group, user)
    Tournament.transaction do
      team = Team.create!(tournament_group: tournament_group)
      outing = GolfOuting.create!(team: team, user: user)
      scorecard = Scorecard.create!(golf_outing: outing)
      
      self.course_holes.each_with_index do |hole, i|
        score = Score.create!(scorecard: scorecard, course_hole: hole, sort_order: i)
      end
    end
  end
  
  def remove_player_from_group(tournament_group, user)
    tournament_group.teams.each do |team|
      team.golf_outings.each do |outing|
        if outing.user == user
          outing.destroy
          
          team.destroy if team.golf_outings.count == 0
          
          break
        end
      end
    end
  end

end