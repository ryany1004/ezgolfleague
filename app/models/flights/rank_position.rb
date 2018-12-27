module Flights
	class RankPosition
		attr_accessor :flight
    attr_accessor :sorted_results

    def self.compute_rank(flight)
    	rank_computer = self.new
    	rank_computer.flight = flight
      scoring_computer = self.scoring_rule.scoring_computer

      reorder_param = scoring_computer.rank_results_sort_reorder_param
      sort_descending = scoring_computer.rank_results_sort_descending

      rank_computer.combine_team_score_results if scoring_computer.rank_should_combine_daily_team_results?
      rank_computer.sort_by_parameter(reorder_param, sort_descending)

    	rank_computer.default_compute_rank(sort_param)
    end

    def tournament_day_results
      flight.tournament_day_results
    end

    def combine_team_score_results
      computed_teams = []
      team_results = []

      self.flight.users.each do |u|
        team = self.flight.tournament_day.daily_team_for_player(u)
        unless team.blank? || computed_teams.include?(team)
          team.users.each do |team_user| #must re-score users first
            self.flight.tournament_day.score_user(team_user)
          end

          primary_user = team.users.first
          primary_scorecard = self.flight.tournament_day.primary_scorecard_for_user(primary_user)
          result_name = Users::ResultName.result_name_for_user(primary_user, self.flight.tournament_day)

          results = self.flight.tournament_day_results.where(user: team.users).where(aggregated_result: false)

          if results.sum(:net_score) > 0
            Rails.logger.info { "Summing results of #{results.count} results for team #{result_name}." }

            team_results << TournamentDayResult.new(aggregated_result: true, tournament_day: self.flight.tournament_day, user: primary_user, name: result_name, primary_scorecard: primary_scorecard, flight: self.flight, gross_score: results.sum(:gross_score), net_score: results.sum(:net_score), adjusted_score: results.sum(:adjusted_score), front_nine_gross_score: results.sum(:front_nine_gross_score), front_nine_net_score: results.sum(:front_nine_net_score), back_nine_net_score: results.sum(:back_nine_net_score), par_related_net_score: results.sum(:par_related_net_score), par_related_gross_score: results.sum(:par_related_gross_score))
          end

          computed_teams << team
        end
      end

      self.flight.tournament_day_results.destroy_all

      team_results.each do |r|
        r.save
      end

      self.tournament_day_results.reload
    end

    # Sort

    def sort_by_parameter(parameter, descending = false)
      parameter = parameter + " DESC" if descending

    	self.sorted_results = tournament_day_results.reorder(parameter)
    end

    # Rank

    def default_compute_rank(sort_parameter)
      last_rank = 0
      last_score = 0
      quantity_at_rank = 0

      Rails.logger.debug { "Ranking #{self.sorted_results.count} results" }

      self.sorted_results.each_with_index do |result, i|
        #rank = last rank + 1
        #unless last_score are the same, then rank does not change
        #when last_score then does differ, need to move the rank up the number of slots

        if result.send(sort_parameter) != last_score
          rank = last_rank + 1

          if quantity_at_rank != 0
            quantity_at_rank = 0

            rank = i + 1
          end

          last_rank = rank
          last_score = result.send(sort_parameter)
        else
          if last_rank == 0
            rank = 1
          else
            rank = last_rank
          end

          quantity_at_rank = quantity_at_rank + 1
        end

        Rails.logger.debug { "Rank of #{rank} for #{result.name}. Net score: #{result.net_score}. Back Nine Net Score (if applicable): #{result.back_nine_net_score}. Param: #{sort_parameter}: #{result.send(sort_parameter)}" }

        result.sort_rank = i
        result.rank = rank
        result.save
      end
    end

    private

    def scoring_rule
    	flight.tournament_day.scorecard_base_scoring_rule
    end

	end
end