class TournamentMailer < ApplicationMailer

  def signup_open(tournament, user)
    @tournament = tournament
    @user = user
    @registration_url = "http://ezgolfleague.herokuapp.com/leagues/#{@tournament.league.id}/tournaments" #TODO: UPDATE

    mail(to: @user.email, subject: 'EZGolfLeague - A New Tournament is Open for Registration')
  end

  def signup_closing(tournament, user)
    @tournament = tournament
    @user = user
    @registration_url = "http://ezgolfleague.herokuapp.com/leagues/#{@tournament.league.id}/tournaments" #TODO: UPDATE

    mail(to: @user.email, subject: 'EZGolfLeague - Tournament Registration is About to Close')
  end

  def tournament_dues_payment_confirmation(user, tournament)
    @user = user
    @tournament = tournament
    @league_season = @tournament.league_season

    mail(to: @league_season.league.dues_payment_receipt_email_addresses, subject: "Tournament Dues Payment: #{@user.complete_name}")
  end

  def tournament_payment_receipt(user, tournament)
    @user = user
    @tournament = tournament
    @league_season = @tournament.league_season

    @contests = []
    @tournament.tournament_days.each do |td|
      td.contests.each do |c|
        @contests << c if c.users.include? @user
      end
    end

    mail(to: @user.email, subject: "Tournament Payment Receipt: #{@user.complete_name}", bcc: @league_season.league.dues_payment_receipt_email_addresses)
  end

  def tournament_coming_up(tournament, user)
    @tournament = tournament
    @user = user
    @registration_url = "http://ezgolfleague.herokuapp.com/leagues/#{@tournament.league.id}/tournaments" #TODO: UPDATE

    mail(to: @user.email, subject: 'EZGolfLeague - Your Tournament is Coming Up')
  end

end
