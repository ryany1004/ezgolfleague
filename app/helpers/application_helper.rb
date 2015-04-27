module ApplicationHelper
  
  def human_boolean(boolean)
    boolean ? 'Yes' : 'No'
  end
  
  def user_is_league_admin(user, league)
    return true if user.is_super_user
    return false if user.blank?
    return false if league.blank?
    
    membership = league.membership_for_user(user)
    
    unless membership.blank?
      return membership.is_admin
    else
      return false
    end
  end

  def bootstrap_class_for(flash_type)
    case flash_type
      when "success"
        "alert-success"   # Green
      when "error"
        "alert-danger"    # Red
      when "alert"
        "alert-warning"   # Yellow
      when "notice"
        "alert-info"      # Blue
      else
        flash_type.to_s
    end
  end
  
  def team_member_names_without_user(team, user)
    members = []
    
    team.golf_outings.each do |outing|
      members << outing.user unless members.include? outing.user or outing.user == user
    end
    
    names = ""
    
    members.each do |m|
      names = "#{names}#{m.complete_name}<br/>"
    end
    
    return names.html_safe
  end
  
  def handicap_allowance_strokes_for_hole(handicap_allowance, course_hole)  
    handicap_allowance.each do |h|      
      if h[:course_hole] == course_hole        
        return h[:strokes]
      end
    end
    
    return 0
  end

end
