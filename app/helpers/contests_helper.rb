module ContestsHelper
  
  def humanize_winners(winners)
    return nil if winners.blank?
    
    html = ""
    
    winners.each do |winner|
      html << "#{winner[:user].complete_name}<br/>"
    end
    
    return html
  end
  
end
