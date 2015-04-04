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
  
end
