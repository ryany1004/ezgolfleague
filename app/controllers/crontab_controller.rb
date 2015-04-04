class CrontabController < ApplicationController
  
  def send_tournament_registration_emails
    tournaments = Tournament.where("signup_opens_at >= ? AND signup_opens_at < ?", Date.today, Date.tomorrow)
    
    tournaments.each do |t|
      t.league.users.each do |u|
        TournamentMailer.signup_open(t, u).deliver_later
      end
    end
    
    render :nothing => true
  end
  
  def send_tournament_registration_reminder_emails
    tournaments = Tournament.where("signup_closes_at >= ? AND signup_closes_at < ?", Date.today, Date.tomorrow)
    
    tournaments.each do |t|
      t.league.users.each do |u|
        TournamentMailer.signup_closing(t, u).deliver_later
      end
    end
    
    render :nothing => true
  end
  
end
