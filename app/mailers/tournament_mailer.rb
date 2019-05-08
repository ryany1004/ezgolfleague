class TournamentMailer < ApplicationMailer
  def signup_open(tournament, user)
    @tournament = tournament
    @user = user
    @registration_url = "https://app.ezgolfleague.com/play/dashboard"

    mail(to: @user.email, subject: 'EZGolfLeague - A New Tournament is Opening for Registration Today')
  end

  def signup_closing(tournament, user)
    @tournament = tournament
    @user = user
    @registration_url = "https://app.ezgolfleague.com/play/dashboard"

    mail(to: @user.email, subject: 'EZGolfLeague - Tournament Registration is About to Close')
  end

  def tournament_dues_payment_confirmation(user, tournament)
    @user = user
    @tournament = tournament
    @league_season = @tournament.league_season

    mail(to: @league_season.league.dues_payment_receipt_email_addresses, subject: "Tournament Dues Payment: #{@user.complete_name}") unless @league_season.league.dues_payment_receipt_email_addresses.blank?
  end

  def tournament_player_paying_later(user, tournament)
    @user = user
    @tournament = tournament
    @league_season = @tournament.league_season
    @dues = @tournament.dues_for_user(@user, false)

    mail(to: @league_season.league.dues_payment_receipt_email_addresses, subject: "Tournament Registration: #{@user.complete_name}") unless @league_season.league.dues_payment_receipt_email_addresses.blank?
  end

  def tournament_player_cancelled(user, tournament)
    @user = user
    @tournament = tournament
    @league_season = @tournament.league_season

    mail(to: @league_season.league.dues_payment_receipt_email_addresses, subject: "Tournament Cancellation: #{@user.complete_name}") unless @league_season.league.dues_payment_receipt_email_addresses.blank?
  end

  def tournament_registrations(tournament)
    @tournament = tournament
    @league_season = @tournament.league_season

    mail(to: @league_season.league.dues_payment_receipt_email_addresses, subject: "Tournament Registrations: #{@tournament.name}") unless @league_season.league.dues_payment_receipt_email_addresses.blank?
  end

  def tournament_payment_receipt(user, tournament, total_charged)
    @tournament = tournament
    league_season = @tournament.league_season

    total_cost = @tournament.mandatory_dues_amount

    @cost_lines = [
      {name: "#{@tournament.name} Fees", price: @tournament.mandatory_dues_amount}
    ]

    @tournament.tournament_days.each do |td|
      td.optional_scoring_rules_with_dues.each do |r|
        if r.dues_amount == 0 or r.users.include? user
          total_cost += r.dues_amount

          @cost_lines << {name: r.name, price: r.dues_amount}
        end
      end
    end

    credit_card_fees = Stripe::StripeFees.fees_for_transaction_amount(total_cost)

    @cost_lines << {name: "Credit Card Fees", price: credit_card_fees}
    @cost_lines << {name: "Total", price: total_charged}

    mail(to: user.email, from: "do_not_reply@ezgolfleague.com", subject: "Tournament Payment Receipt: #{user.complete_name}", bcc: league_season.league.dues_payment_receipt_email_addresses)
  end

  def tournament_coming_up(tournament, user)
    @tournament = tournament
    @user = user
    @registration_url = "https://app.ezgolfleague.com/play/dashboard"

    mail(to: @user.email, subject: 'EZGolfLeague - Your Tournament is Coming Up')
  end
end
