json.tournament_day_results do
	json.partial! 'tournament_result', collection: @tournament_results, as: :tournament_result
end
json.uses_scoring_groups	@uses_scoring_groups