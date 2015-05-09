module ContestsHelper
  
  def humanize_winners(winners)
    return nil if winners.blank?
    
    html = ""
    
    winners.each do |winner|
      html << "#{winner[:user].complete_name}"
      
      html << "<br/>" if winner != winners.last
    end
    
    return html.html_safe
  end
  
end
