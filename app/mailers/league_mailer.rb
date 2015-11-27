class LeagueMailer < ApplicationMailer
  
  def league_message(user, subject, contents)
    @user = user
    @contents = contents

    mail(to: @user.email, subject: "League Message: #{subject}")
  end
  
  def league_dues_payment_confirmation(user, league_season)
    @user = user
    @league_season = league_season
    @league = league_season.league
    
    mail(to: @league_season.league.dues_payment_receipt_email_addresses, subject: "League Dues Payment: #{@user.complete_name}")
  end
  
  def renew_dues(user, league)
    @user = user
    @league = league

    mail(to: @user.email, subject: 'EZGolfLeague - Renew Your League Membership')
  end
  
end
