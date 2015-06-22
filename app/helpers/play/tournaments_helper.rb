module Play::TournamentsHelper
  
  def format_winners(winners)
    html = ""
    
    winners.each do |winner|
      html << winner[:user].complete_name + " "
    end
    
    return html
  end
  
  def format_payout(winners)
    html = ""
    
    winners.each do |winner|
      html << number_to_currency(winner[:amount]) + " "
    end
    
    return html
  end
  
  def format_points(winners)
    html = ""
    
    winners.each do |winner|
      if winner[:points].blank?
        html << "0 " 
      else
        html << winner[:points].to_s + " " 
      end
    end
    
    return html
  end
    
end
