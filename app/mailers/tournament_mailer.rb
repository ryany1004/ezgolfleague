class TournamentMailer < ApplicationMailer

  def signup_open(tournament, user)
    @tournament = tournament
    @user = user
    @registration_url = "https://app.ezgolfleague.com/leagues/#{@tournament.league.id}/tournaments"

    mail(to: @user.email, subject: 'EZGolfLeague - A New Tournament is Open for Registration')
  end

  def signup_closing(tournament, user)
    @tournament = tournament
    @user = user
    @registration_url = "https://app.ezgolfleague.com/leagues/#{@tournament.league.id}/tournaments"

    mail(to: @user.email, subject: 'EZGolfLeague - Tournament Registration is About to Close')
  end

  def tournament_dues_payment_confirmation(user, tournament)
    @user = user
    @tournament = tournament
    @league_season = @tournament.league_season

    mail(to: @league_season.league.dues_payment_receipt_email_addresses, subject: "Tournament Dues Payment: #{@user.complete_name}")
  end

  def tournament_payment_receipt(user, tournament)
    @tournament = tournament
    league_season = @tournament.league_season

    total_cost = @tournament.dues_amount

    @cost_lines = [
      {:name => "#{@tournament.name} Fees", :price => @tournament.dues_amount}
    ]

    @tournament.tournament_days.each do |td|
      td.contests.each do |c|
        if c.dues_amount == 0 or c.users.include? @user
          total_cost += c.dues_amount

          @cost_lines << {:name => c.name, :price => c.dues_amount}
        end
      end
    end

    credit_card_fees = Stripe::StripeFees.fees_for_transaction_amount(total_cost)
    total_cost += credit_card_fees

    @cost_lines << {:name => "Credit Card Fees", :price => credit_card_fees}
    @cost_lines << {:name => "Total", :price => total_cost}

    mail(to: user.email, subject: "Tournament Payment Receipt: #{user.complete_name}", bcc: league_season.league.dues_payment_receipt_email_addresses)
  end

  def tournament_coming_up(tournament, user)
    @tournament = tournament
    @user = user
    @registration_url = "http://ezgolfleague.herokuapp.com/leagues/#{@tournament.league.id}/tournaments" #TODO: UPDATE

    mail(to: @user.email, subject: 'EZGolfLeague - Your Tournament is Coming Up')
  end

end
