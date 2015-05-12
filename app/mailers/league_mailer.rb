class LeagueMailer < ApplicationMailer
  
  def league_message(user, subject, contents)
    @user = user
    @contents = contents

    mail(to: @user.email, subject: "League Message: #{subject}")
  end
  
  def renew_dues(user, league)
    @user = user
    @league = league

    mail(to: @user.email, subject: 'EZGolfLeague - Renew Your League Membership')
  end
  
end
