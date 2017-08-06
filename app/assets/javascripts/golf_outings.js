function removeSelectedGolfersFromDropdowns(selectedGolfers) {
  var chosenSelects = $("#user-select .chosen-select");
  var elementsUpdated = [];

  for (i = 0; i < chosenSelects.length; i++) {
    var selectItem = chosenSelects[i];
    var chosenSelectItem = $(selectItem);

    for (x = 0; x < selectedGolfers.length; x++) {
      var golferId = selectedGolfers[x].id;

      if (chosenSelectItem.chosen().val() != golferId) {
        for (j = 0; j < selectItem.options.length; j++) {
          var child = selectItem.options[j];

          if (child.value == golferId) {
            $(child).remove();
          }
        }
      } else {
        elementsUpdated.push(selectItem.parentElement.parentElement.parentElement);

        selectItem.parentElement.parentElement.style.display = 'none';
        selectItem.parentElement.parentElement.parentElement.querySelector("#user-hidden").innerHTML = selectedGolfers[x].name;
      }
    }
  }

  chosenSelects.trigger("chosen:updated");

  $(".search-choice-close").remove();

  return elementsUpdated;
}

function placeButtonsForGolfers(selectedGolfers, elementsUpdated) {
  for (i = 0; i < elementsUpdated.length; i++) {
    var golfer = selectedGolfers[i];
    var element = $(elementsUpdated[i]);

    element.children("#action-buttons").html(golfer["disqualifyButton"] + "&nbsp;" + golfer["removeButton"]);
  }
}
