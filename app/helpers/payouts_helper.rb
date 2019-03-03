module PayoutsHelper
  def flight_or_group_display_name(tournament)
    if tournament.league.allow_scoring_groups
      "Group"
    else
      "Flight"
    end
  end
end
