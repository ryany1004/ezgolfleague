json.cache! ['v1', tournament_day_result] do
  json.user_id                  tournament_day_result.id
  json.name 										tournament_day_result.name
  json.net_score 								tournament_day_result.net_score
  json.back_nine_net_score 			tournament_day_result.back_nine_net_score
  json.gross_score 							tournament_day_result.gross_score
  json.par_related_net_score 		tournament_day_result.par_related_net_score
  json.par_related_gross_score 	tournament_day_result.par_related_gross_score
  json.thru 										tournament_day_result.thru
  json.points 									tournament_day_result.points
  json.ranking 									tournament_day_result.rank
  json.user_id 									tournament_day_result.user.id
  json.matchup_position         tournament_day_result.matchup_position
end
