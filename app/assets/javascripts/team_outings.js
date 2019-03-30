function removeSelectedTeamsFromDropdowns(selectedTeams) {
  var chosenSelects = $("#user-select .chosen-select");
  var elementsUpdated = [];

  for (i = 0; i < chosenSelects.length; i++) {
    var selectItem = chosenSelects[i];
    var chosenSelectItem = $(selectItem);

    for (x = 0; x < selectedTeams.length; x++) {
      var teamId = selectedTeams[x].id;

      if (chosenSelectItem.chosen().val() != teamId) {
        for (j = 0; j < selectItem.options.length; j++) {
          var child = selectItem.options[j];

          if (child.value == teamId) {
            $(child).remove();
          }
        }
      } else {
        elementsUpdated.push(selectItem.parentElement.parentElement.parentElement.parentElement);

        selectItem.parentElement.parentElement.style.display = 'none';
        selectItem.parentElement.parentElement.parentElement.querySelector("#user-hidden").innerHTML = selectedTeams[x].name;
      }
    }
  }

  chosenSelects.trigger("chosen:updated");

  $(".search-choice-close").remove();

  return elementsUpdated;
}

function placeButtonsForTeams(selectedTeams, elementsUpdated) {
  for (i = 0; i < elementsUpdated.length; i++) {
    var team = selectedTeams[i];
    var element = $(elementsUpdated[i]);

    element.children("#action-buttons").html(team["specifyPlayersButton"] + "&nbsp;" + team["removeButton"]);
  }
}