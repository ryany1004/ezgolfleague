namespace :payment_data_cleanup do
  desc 'Payment Data Cleanup'
  task change: :environment do
    #find payments that are not from credit cards, delete them
    Payment.where("payment_source != 'Credit Card'").destroy_all

    #for each credit card payment, create a deduction
    Payment.where("payment_source = 'Credit Card'").each do |p|
      new_payment = Payment.create(user: p.user, payment_source: "Data Cleanup", payment_amount: (p.payment_amount * -1.0), tournament: p.tournament, league_season: p.league_season, contest: p.contest, created_at: p.created_at, updated_at: p.updated_at)

      p.original_payment = new_payment
      p.save
    end

    #for each tournament in the past, go through and for each person WHO DOES NOT HAVE A PAYMENT, create a debit and credit
      #link them together
      #include an import note
    Tournament.all_past(nil).each do |t|
      t.players.each do |player|
        existing_tournament_payments = t.payments.where(user: player)

        if existing_tournament_payments.blank?
          debit = Payment.create(user: player, payment_amount: t.dues_for_user(player, false) * -1.0, tournament: t, payment_source: "Data Cleanup Debit")
          credit = Payment.create(user: player, payment_amount: t.dues_for_user(player, false), tournament: t, payment_source: "Data Cleanup Credit", original_payment: debit)
        end
      end

      #contests
      t.tournament_days.each do |d|
        d.contests.each do |c|
          c.users.each do |player|
            existing_contest_payments = c.payments.where(user: player)

            if existing_contest_payments.blank?
              debit = Payment.create(user: player, payment_amount: c.dues_for_user(player, false) * -1.0, contest: c, payment_source: "Data Cleanup Debit")
              credit = Payment.create(user: player, payment_amount: c.dues_for_user(player, false), contest: c, payment_source: "Data Cleanup Credit", original_payment: debit)
            end
          end
        end
      end
    end

    #future tournaments - players without any payments should have a debit
    Tournament.all_future(nil).each do |t|
      t.players.each do |player|
        existing_tournament_payments = t.payments.where(user: player)

        if existing_tournament_payments.blank?
          debit = Payment.create(user: player, payment_amount: t.dues_for_user(player, false) * -1.0, tournament: t, payment_source: "Data Cleanup Debit")
        end
      end
    end

    #for each league, go through and for each league season
      #go through and create a debit and credit
    League.all.each do |l|
      l.league_seasons.each do |season|
        l.users.each do |player|
          existing_season_payments = season.payments.where(user: player)

          if existing_season_payments.blank?
            debit = Payment.create(user: player, payment_amount: l.dues_for_user(player, false) * -1.0, league_season: season, payment_source: "Data Cleanup Debit")
            credit = Payment.create(user: player, payment_amount: l.dues_for_user(player, false), league_season: season, payment_source: "Data Cleanup Credit", original_payment: debit)
          end
        end
      end
    end
  end
end
