module Findable
  extend ActiveSupport::Concern

  module ClassMethods
    def all_today(leagues = nil)
      return Tournament.tournaments_happening_at_some_point(Time.zone.now.at_beginning_of_day, Time.zone.now.at_end_of_day, leagues)
    end
    
    def all_upcoming(leagues = nil, end_date = nil)
      return Tournament.tournaments_happening_at_some_point(Time.zone.now.at_beginning_of_day, end_date, leagues)
    end
    
    def all_past(leagues = nil, start_date = nil)
      return Tournament.tournaments_happening_at_some_point(start_date, Time.zone.now.at_beginning_of_day, leagues)
    end
  
    def tournaments_happening_at_some_point(start_date, end_date, leagues)
      relation = Tournament.includes(:tournament_days)
            
      unless leagues.blank?
        league_ids = leagues.map { |n| n.id }
        
        relation = relation.joins(:league).where("leagues.id IN (?)", league_ids)
      end

      unless start_date.blank?
        relation = relation.where("tournament_days.tournament_at >= ? OR tournament_days_count = 0", start_date)
      end
    
      unless end_date.blank?
        relation = relation.where("tournament_days.tournament_at <= ? OR tournament_days_count = 0", end_date)
      end

      relation = relation.order("tournament_at")
    
      return relation.references(:tournament_days)
    end
    
  end

end