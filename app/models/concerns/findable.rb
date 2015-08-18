module Findable
  extend ActiveSupport::Concern

  module ClassMethods
    def all_today(leagues = nil)
      return Tournament.tournaments_happening_at_some_point(Time.zone.now.at_beginning_of_day, Time.zone.now.at_end_of_day, leagues)
    end
    
    def all_upcoming(leagues = nil)
      return Tournament.tournaments_happening_at_some_point(Time.zone.now.at_beginning_of_day, nil, leagues)
    end
    
    def all_past(leagues = nil)
      return Tournament.tournaments_happening_at_some_point(nil, Time.zone.now.at_beginning_of_day, leagues)
    end
    
    def tournaments_happening_at_some_point(start_date, end_date, leagues)
      relation = Tournament.all
      
      unless leagues.blank?
        league_ids = leagues.map { |n| n.id }
        
        relation = relation.joins(:league).where("leagues.id IN (?)", league_ids)
      end

      unless start_date.blank?
        relation = relation.joins(:tournament_days).where("tournament_at >= ?", start_date)
        #relation = relation.joins('LEFT OUTER JOIN tournament_days ON tournament_days.tournament_id = tournaments.id').where("tournament_at >= ?", start_date)
      end
    
      unless end_date.blank?
        relation = relation.joins(:tournament_days).where("tournament_at <= ?", end_date)
        #relation = relation.joins('LEFT OUTER JOIN tournament_days ON tournament_days.tournament_id = tournaments.id').where("tournament_at <= ?", end_date)
      end

      relation = relation.order("tournament_at")
    
      return relation
    end
  end

end