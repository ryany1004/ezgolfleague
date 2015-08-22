module Play::TournamentsHelper
  
  def cache_key_for_tournament_day_with_prefix(tournament_day, prefix)
    max_updated_at = tournament_day.updated_at.try(:utc).try(:to_s, :number)
    cache_key = "tournament_days/#{prefix}-#{tournament_day.id}-#{max_updated_at}"
    
    Rails.logger.debug { "Tournament Day Cache Key: #{cache_key}" }
    
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
    
end
