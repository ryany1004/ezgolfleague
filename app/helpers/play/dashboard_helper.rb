module Play::DashboardHelper
  
  def scorecard_links_for_user_in_tournament(user, tournament)
    link_html = ""
    
    tournament.tournament_days.each do |day|
      if tournament.is_finalized
        link_html << link_to("View", play_scorecard_path(day.primary_scorecard_for_user(user)))
      else
        link_html << link_to("Edit", play_scorecard_path(day.primary_scorecard_for_user(user)))
      end
    
      link_html << "<br/>" if day != tournament.tournament_days.last
    end

    return link_html.html_safe
  end
  
end
