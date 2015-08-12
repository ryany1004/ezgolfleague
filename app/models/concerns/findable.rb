module Findable
  extend ActiveSupport::Concern

  module ClassMethods
    def all_today(league = nil)
      return Tournament.tournaments_happening_at_some_point(Time.zone.now.at_beginning_of_day, Time.zone.now.at_end_of_day, league)
    end
    
    def all_upcoming(league = nil)
      return Tournament.tournaments_happening_at_some_point(Time.zone.now.at_beginning_of_day, nil, league)
    end
    
    def all_past(league = nil)
      return Tournament.tournaments_happening_at_some_point(nil, Time.zone.now.at_beginning_of_day, league)
    end
    
    def tournaments_happening_at_some_point(start_date, end_date, league)
      relation = Tournament.all

      relation = relation.where(league: league) unless league.blank?
    
      unless start_date.blank?
        relation = relation.joins(:tournament_days).where("tournament_at >= ?", start_date)
      end
    
      unless end_date.blank?
        relation = relation.joins(:tournament_days).where("tournament_at <= ?", end_date)
      end

      relation = relation.order("tournament_at")
    
      return relation
    end
  end

end