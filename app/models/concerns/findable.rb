module Findable
  extend ActiveSupport::Concern

  module ClassMethods
    def all_today(leagues = nil)
      Tournament.tournaments_happening_at_some_point(Time.zone.now.at_beginning_of_day, Time.zone.now.at_end_of_day, leagues, true)
    end

    def all_upcoming(leagues = nil, end_date = nil)
      Tournament.tournaments_happening_at_some_point(Time.zone.now.at_beginning_of_day, end_date, leagues, true)
    end

    def all_past(leagues = nil, start_date = nil)
      Tournament.tournaments_happening_at_some_point(start_date, Time.zone.now.at_beginning_of_day, leagues, true)
    end

    def all_unconfigured(leagues = nil)
      Tournament.tournaments_happening_at_some_point(nil, nil, leagues, false)
    end

    def past_for_league_season(league_season)
      if league_season.ends_at > Date.current.in_time_zone
        end_time = Time.zone.now.at_beginning_of_day
      else
        end_time = league_season.ends_at
      end

      Tournament.tournaments_happening_at_some_point(league_season.starts_at, end_time, [league_season.league])
    end

    def tournaments_happening_at_some_point(start_date, end_date, leagues, restrict_to_configured = true)
      relation = Tournament.includes(:league)

      unless leagues.blank?
        league_ids = leagues.map { |n| n.id }

        relation = relation.includes(:league).where("leagues.id IN (?)", league_ids).references(:league)
      end

      unless start_date.blank?
        relation = relation.where("tournament_starts_at >= ? OR tournament_days_count = 0", start_date)
      end

      unless end_date.blank?
        relation = relation.where("tournament_starts_at <= ? OR tournament_days_count = 0", end_date)
      end

      if restrict_to_configured
        relation = relation.where("tournament_starts_at IS NOT NULL")
      else
        relation = relation.where("tournament_starts_at IS NULL")
      end

      relation = relation.order(:tournament_starts_at)

      relation = relation.references(:tournament_days)

      relation
    end

  end

end
