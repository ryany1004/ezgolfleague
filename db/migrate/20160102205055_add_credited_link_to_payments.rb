class AddCreditedLinkToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :payment_id, :integer
    
    Payment.where("payment_amount > 0 AND (tournament_id IS NOT NULL OR league_season_id IS NOT NULL OR contest_id IS NOT NULL)").each do |p|      
      refunds = Payment.where(user: p.user)
      
      unless p.tournament.blank?
        refunds = refunds.where(tournament: p.tournament)
      end
      
      unless p.league_season.blank?
        refunds = refunds.where(league_season: p.league_season)
      end
      
      unless p.contest.blank?
        refunds = refunds.where(contest: p.contest)
      end
      
      refunds.each do |r|
        p.credits << r
        p.save
      end
      
    end
  end
end
