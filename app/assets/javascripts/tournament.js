function loadTeamOptions(optionType, league_id, tournament_id, tournament_day_id, sender) {
  $("#teamTypeOptions"+ optionType + tournament_day_id).load("/leagues/" + league_id + "/tournaments/" + tournament_id + "/options.js?day="+ tournament_day_id +"&tournament_group_id=" + sender.value);
}
