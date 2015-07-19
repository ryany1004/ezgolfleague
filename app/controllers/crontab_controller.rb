class CrontabController < ApplicationController
  
  def update_all_players_from_ghin
    logger.info { "Importing From GHIN" }
    
    Importers::GHINImporter.import_for_all_users
    
    render :nothing => true
  end
  
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
  
  def send_tournament_coming_up_emails
    number_of_days = params[:days_away]
    
    start_date = Date.today + number_of_days
    end_date = start_date + 1.day

    tournaments = Tournament.where("tournament_at >= ? AND tournament_at < ?", start_date, end_date)
    
    tournaments.each do |t|
      t.players.each do |u|
        TournamentMailer.tournament_coming_up(t, u).deliver_later
      end
    end
    
    render :nothing => true
  end
  
end
