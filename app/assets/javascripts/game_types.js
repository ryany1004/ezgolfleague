function loadGameTypeOptions(league_id, tournament_id, sender) {
  $("#gameTypeOptions").load("/leagues/" + league_id + "/tournaments/" + tournament_id + "/game_types/options.js?game_type_id=" + sender.value);
}