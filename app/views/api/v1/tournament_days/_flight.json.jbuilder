json.cache! ['v1', flight] do
	json.flight_number					flight.flight_number
	json.display_name 					flight.display_name
	json.api_display_name 			flight.api_display_name
	
	json.players flight.scorecard_base_scoring_rule_tournament_day_results, partial: 'tournament_day_result', as: :tournament_day_result
end