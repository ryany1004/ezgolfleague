json.cache! ['v1', ranking] do
  json.flight_number 			ranking[:flight_number]
  json.name								ranking[:name]
  json.id									ranking[:id]
  json.ranking						ranking[:ranking]
  json.points							ranking[:points]
  json.net_score					ranking[:net_score]
  json.gross_score				ranking[:gross_score]
  json.matchup_position   ranking[:matchup_position]
end
