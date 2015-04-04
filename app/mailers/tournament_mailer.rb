class TournamentMailer < ApplicationMailer
  
  def signup_open(tournament, user)
    @tournament = tournament
    @user = user
    @registration_url = "http://ezgolfleague.herokuapp.com/leagues/#{@tournament.league.id}/tournaments" #TODO: UPDATE

    mail(to: @user.email, subject: 'EZGolfLeague - A New Tournament is Open for Registration'
  end
  
  def signup_closing(tournament, user)
    @tournament = tournament
    @user = user
    @registration_url = "http://ezgolfleague.herokuapp.com/leagues/#{@tournament.league.id}/tournaments" #TODO: UPDATE

    mail(to: @user.email, subject: 'EZGolfLeague - Tournament Registration is About to Close'
  end
  
end
