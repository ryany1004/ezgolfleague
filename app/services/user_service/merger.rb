module UserService
  module Merger
    extend self

    def call(source_user, destination_user, should_delete = false)
      User.transaction do
        merge_league_memberships(source_user, destination_user)
        merge_league_season_teams(source_user, destination_user)
        merge_golf_outings(source_user, destination_user)
        merge_payout_results(source_user, destination_user)
        merge_payments(source_user, destination_user)
        merge_scoring_rules(source_user, destination_user)
        merge_league_season_rankings(source_user, destination_user)
        merge_tournament_day_results(source_user, destination_user)
        merge_child_users(source_user, destination_user)
        merge_flights(source_user, destination_user)
        merge_daily_teams(source_user, destination_user)

        destination_user.save

        if should_delete
          source_user.destroy
        else
          source_user.save
        end
      end
    end

    private

    def merge_league_memberships(source_user, destination_user)
      source_user.league_memberships.each do |membership|
        destination_user.league_memberships << membership unless destination_user.league_memberships.include? membership
      end
      source_user.league_memberships.clear
    end

    def merge_league_season_teams(source_user, destination_user)
      destination_user.league_season_teams += source_user.league_season_teams
    end

    def merge_golf_outings(source_user, destination_user)
      destination_user.golf_outings += source_user.golf_outings
    end

    def merge_payout_results(source_user, destination_user)
      destination_user.payout_results += source_user.payout_results
    end

    def merge_payments(source_user, destination_user)
      destination_user.payments += source_user.payments
    end

    def merge_scoring_rules(source_user, destination_user)
      destination_user.scoring_rules += source_user.scoring_rules
    end

    def merge_league_season_rankings(source_user, destination_user)
      destination_user.league_season_rankings += source_user.league_season_rankings
    end

    def merge_tournament_day_results(source_user, destination_user)
      destination_user.tournament_day_results += source_user.tournament_day_results
    end

    def merge_child_users(source_user, destination_user)
      destination_user.child_users += source_user.child_users
      source_user.child_users.clear

      destination_user.parent_user = source_user.parent_user
      source_user.parent_user = nil
    end

    def merge_flights(source_user, destination_user)
      destination_user.flights += source_user.flights
    end

    def merge_daily_teams(source_user, destination_user)
      destination_user.daily_teams += source_user.daily_teams
    end
  end
end
