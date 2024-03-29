module Reports
  class AdjustedScores < Report
    attr_accessor :results

    def initialize(tournament_day)
      super(tournament_day)

      self.results = self.tournament_day.stroke_play_scoring_rule&.tournament_day_results.order(:flight_id)
    end
  end
end
