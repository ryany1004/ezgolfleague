class CrontabController < ApplicationController

  def update_all_players_from_ghin
    logger.info { "Importing From GHIN" }

    Importers::GHINImporter.import_for_all_users

    head :ok, content_type: "text/html"
  end

  def send_tournament_registration_emails
    tournaments = Tournament.where("signup_opens_at >= ? AND signup_opens_at < ? AND tournament_starts_at IS NOT NULL", Date.current.in_time_zone, Date.tomorrow.in_time_zone)

    tournaments.each do |t|
      t.league.users.each do |u|
        TournamentMailer.signup_open(t, u).deliver_later
      end
    end

    head :ok, content_type: "text/html"
  end

  def send_tournament_registration_reminder_emails
    tournaments = Tournament.where("signup_closes_at >= ? AND signup_closes_at < ? AND tournament_starts_at IS NOT NULL", Date.current.in_time_zone, Date.tomorrow.in_time_zone)

    tournaments.each do |t|
      t.league.users.each do |u|
      	Rails.logger.info { "Sending closing reminder to #{u.complete_name} #{u.id} for #{t.name}" }

        TournamentMailer.signup_closing(t, u).deliver_later
      end
    end

    head :ok, content_type: "text/html"
  end

  def send_tournament_coming_up_emails
    number_of_days = params[:days_away].to_i

    start_date = Date.current.in_time_zone + number_of_days
    end_date = start_date + 1.day

    tournaments = Tournament.where("tournament_starts_at >= ? AND tournament_starts_at < ? AND tournament_starts_at IS NOT NULL", start_date, end_date)

    tournaments.each do |t|
      t.players.each do |u|
        TournamentMailer.tournament_coming_up(t, u).deliver_later
      end
    end

    head :ok, content_type: "text/html"
  end

  def send_tournament_registration_status
    start_date = Date.current.in_time_zone + 72.hours
    end_date = start_date + 1.day

    tournaments = Tournament.where("tournament_starts_at >= ? AND tournament_starts_at < ? AND tournament_starts_at IS NOT NULL", start_date, end_date)

    tournaments.each do |t|
      TournamentMailer.tournament_registrations(t).deliver_later
    end

    head :ok, content_type: "text/html"
  end

end
