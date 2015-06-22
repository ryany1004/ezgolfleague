module Play::TournamentsHelper
  
  def format_winners(winners)
    return "" if winners.blank?
    
    html = ""
    
    winners.each do |winner|
      html << winner[:user].complete_name
      
      html << "<br/>" unless winner == winners.last
    end
    
    return html.html_safe
  end
  
  def format_payout(winners)
    return "" if winners.blank?
    
    html = ""
    
    winners.each do |winner|
      html << number_to_currency(winner[:amount])
      
      html << "<br/>" unless winner == winners.last
    end
    
    return html.html_safe
  end
  
  def format_points(winners)
    return "" if winners.blank?
    
    html = ""
    
    winners.each do |winner|
      if winner[:points].blank?
        html << "0" 
      else
        html << winner[:points].to_s
      end
      
      html << "<br/>" unless winner == winners.last 
    end
    
    return html.html_safe
  end
    
end
