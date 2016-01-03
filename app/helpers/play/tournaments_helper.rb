module Play::TournamentsHelper
  
  def cache_key_for_tournament_day_with_prefix(tournament_day, prefix)
    max_updated_at = tournament_day.updated_at.try(:utc).try(:to_s, :number)
    cache_key = "tournament_days/#{prefix}-#{tournament_day.id}-#{max_updated_at}"
    
    Rails.logger.debug { "Tournament Day Cache Key: #{cache_key}" }
    
    return cache_key
  end
  
  def cache_key_for_tournament_day_leaderboard_with_prefix(tournament_day, prefix)
    cache_key = tournament_day.tournament_day_results_cache_key(prefix)
    
    Rails.logger.debug { "Tournament Day Leaderboard Cache Key: #{cache_key}" }
    
    return cache_key
  end
  
  def format_winners(winners)
    return "" if winners.blank?
    
    html = ""
    
    winners.each_with_index do |winner, i|
      html << winner[:user].complete_name
      
      html << "<br/>" unless i == winners.count - 1
    end
    
    return html.html_safe
  end
  
  def format_payout(winners)
    return "" if winners.blank?
    
    html = ""
    
    winners.each_with_index do |winner, i|
      html << number_to_currency(winner[:amount])
      
      html << "<br/>" unless i == winners.count - 1
    end
    
    return html.html_safe
  end
  
  def format_points(winners)
    return "" if winners.blank?
    
    html = ""
    
    winners.each_with_index do |winner, i|
      if winner[:points].blank?
        html << "0" 
      else
        html << winner[:points].to_s
      end
      
      html << "<br/>" unless i == winners.count - 1
    end
    
    return html.html_safe
  end
  
  def format_results(winners)
    return "" if winners.blank?
    
    html = ""
    
    winners.each_with_index do |winner, i|
      html << winner[:result_value]
      
      html << "<br/>" unless i == winners.count - 1
    end
    
    return html.html_safe
  end
    
  def display_tee_time_or_position(tournament_group)
    if tournament_group.tournament_day.tournament.show_players_tee_times == true
      return tournament_group.tee_time_at.to_s(:time_only)
    else      
      return tournament_group.time_description
    end
  end
  
  def tee_time_position(tournament_group, index, count)
    return tournament_group.time_description
  end

end
