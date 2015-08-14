function loadGameTypeOptions(league_id, tournament_id, tournament_day_id, sender) {
  $("#gameTypeOptions"+ tournament_day_id).load("/leagues/" + league_id + "/tournaments/" + tournament_id + "/game_types/options.js?day="+ tournament_day_id +"&game_type_id=" + sender.value);
}