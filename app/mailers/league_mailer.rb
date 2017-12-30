class LeagueMailer < ApplicationMailer
  def tournament_finalized(tournament)
    @tournament = tournament

    mail(to: @tournament.league.dues_payment_receipt_email_addresses, subject: "#{@tournament.league.name} Tournament Results Calculated")
  end

  def league_message(user, league, subject, contents)
    @user = user
    @contents = contents
    @league = league

    mail(to: @user.email, subject: "#{@league.name}: #{subject}")
  end

  def league_interest(from_user, league)
    @user = from_user
    @league = league

    mail(to: @league.dues_payment_receipt_email_addresses, subject: "#{@league.name}: A User Has Expressed Interest in the League")
  end

  def league_dues_payment_confirmation(user, league_season)
    @user = user
    @league_season = league_season
    @league = league_season.league

    mail(to: @league_season.league.dues_payment_receipt_email_addresses, subject: "#{@league.name} Dues Payment: #{@user.complete_name}")
  end

  def renew_dues(user, league)
    @user = user
    @league = league

    mail(to: @user.email, subject: "#{@league.name} - Renew Your League Membership")
  end
end
