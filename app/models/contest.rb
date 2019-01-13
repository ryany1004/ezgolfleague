#TODO: REMOVE AFTER MIGRATION

class Contest < ApplicationRecord
  # include ContestScoreable
  include Servable

  belongs_to :tournament_day, touch: true

  # handle single winner contests
  belongs_to :overall_winner, class_name: 'ContestResult', foreign_key: 'overall_winner_contest_result_id', dependent: :destroy

  has_many :payments, inverse_of: :contest
  has_many :contest_results, inverse_of: :contest

  # handle multiple hole contests
  has_many :contest_holes, dependent: :destroy
  has_many :course_holes, through: :contest_holes

  has_and_belongs_to_many :users # contestants

  validates :dues_amount, numericality: { greater_than_or_equal_to: 0 }

  def human_type
    if self.contest_type.zero?
      'Custom: Overall Winner'
    elsif self.contest_type == 1
      'Custom: By Hole'
    elsif self.contest_type == 2
      'Net Skins'
    elsif self.contest_type == 3
      'Gross Skins'
    elsif self.contest_type == 4
      'Net Low'
    elsif self.contest_type == 5
      'Gross Low'
    elsif self.contest_type == 6
      'Net Low Tournament Total'
    elsif self.contest_type == 7
      'Gross Low Tournament Total'
    elsif self.contest_type == 8
      'Net Skins + Gross Skins'
    end
  end

  def name_with_cost
    "#{self.name} ($#{self.dues_amount.to_i})"
  end

  def is_team_scored?
    if self.contest_type == 2 || self.contest_type == 3 || self.contest_type == 8
      true
    else
      false
    end
  end

  def dues_for_user(user, include_credit_card_fees = false)
    membership = user.league_memberships.where('league_id = ?', self.tournament_day.tournament.league.id).first

    if membership.blank?
      0
    else
      dues_amount = self.dues_amount

      credit_card_fees = 0
      credit_card_fees = Stripe::StripeFees.fees_for_transaction_amount(dues_amount) if include_credit_card_fees == true

      total = dues_amount + credit_card_fees

      total
    end
  end

  def cost_breakdown_for_user(user, include_credit_card_fees = true)
    membership = user.league_memberships.where("league_id = ?", self.tournament_day.tournament.league.id).first

    cost_lines = [
      { name: "#{self.name} Fees", price: self.dues_amount.to_f, server_id: self.id.to_s }
    ]

    if include_credit_card_fees == true
      cost_lines << {name: "Credit Card Fees", price: Stripe::StripeFees.fees_for_transaction_amount(self.dues_amount)}
    end

    cost_lines
  end

  ##

  def manual_results_entry?
    if self.contest_type < 2
      true
    else
      if self.winners.blank? || self.winners.count == 0
        false
      else
        true
      end
    end
  end

  def allows_overall_winner_points_and_payouts?
    if self.contest_type >= 4 && self.contest_type <= 7
      true
    else
      false
    end
  end

  def combined_contest_results
    if self.is_by_hole? == false
      if self.overall_winner.blank?
        []
      else
        [self.overall_winner]
      end
    else
      results = []

      self.contest_holes.includes(:contest_results).each do |hole|
        hole.contest_results.each do |result|
          results << result
        end
      end

      results
    end
  end

  def remove_results
    self.overall_winner = nil

    self.contest_holes.includes(:contest_results).each do |hole|
      hole.contest_results.destroy_all
    end
  end

  def is_by_hole?
    return false if self.contest_type == 0
    return false if self.contest_type == 4
    return false if self.contest_type == 5
    return false if self.contest_type == 6
    return false if self.contest_type == 7

    true
  end

  def should_sum_winners?
    return true if self.contest_type == 2
    return true if self.contest_type == 3
    return true if self.contest_type == 8

    false
  end

  def can_accept_more_results?
    if self.contest_type == 0 && !self.overall_winner.blank?
      false
    else
      true
    end
  end

  def winners
    if self.is_by_hole? == false
      if self.overall_winner.blank?
        nil
      else
        [{contest_name: self.name, user: self.overall_winner.winner, name: self.overall_winner.winner.complete_name, result_value: self.overall_winner.result_value, amount: self.overall_winner.payout_amount, points: self.overall_winner.points}]
      end
    else
      winners = []

      if self.should_sum_winners? && self.is_team_contest?
        self.tournament_day.daily_teams&.each do |team|
          team_contest_results = ContestResult.where(contest: self).where(winner: team.users)

          amount = team_contest_results.to_a.sum(&:payout_amount)
          points = team_contest_results.to_a.sum(&:points)

          if amount > 0 or points > 0
            winners << {contest_name: self.name, user: team.users.first, name: team.short_name, result_value: "#{team_contest_results.count}", amount: amount, points: points, number_of_wins: team_contest_results.count}
          end
        end
      else
        self.combined_contest_results.each do |result|
          if self.should_sum_winners?
            existing_winner = nil
            winners.each do |w|
              existing_winner = w if w[:user] == result.winner
            end

            if existing_winner.blank?
              winners << {contest_name: self.name, user: result.winner, name: result.winner.try(:complete_name), result_value: "Hole #{result.result_value}", amount: result.payout_amount, points: result.points, number_of_wins: 1}
            else
              existing_winner[:amount] += result.payout_amount
              existing_winner[:points] += result.points

              existing_winner[:result_value] += ", #{result.result_value}"
            end
          else
            winners << {contest_name: self.name, user: result.winner, name: result.winner.try(:complete_name), result_value: result.result_value, amount: result.payout_amount, points: result.points}
          end
        end
      end

      winners.sort! { |x,y| x[:amount] <=> y[:amount] }

      winners
    end
  end

  def add_user(user)
    return if user.blank? || self.users.include?(user)

    self.users << user

    dues = self.dues_for_user(user)
    if dues > 0
      Payment.create(contest: self, payment_amount: dues * -1, user: user, payment_source: "Contest Dues")
    end
  end

  def add_winner(winner, amount, contest_hole = nil, result_value = nil)
    ContestResult.create(contest: self, winner: winner, payout_amount: amount, contest_hole: contest_hole, result_value: result_value)

    self.reload

    self.contest_results.each do |w|
      w.payout_amount = amount
      w.save
    end
  end

  def remove_winner(winner, rebalance_amount = nil)
    results_to_remove = self.contest_results.where(winner: winner)

    unless results_to_remove.blank?
      results_to_remove.destroy_all

      self.reload

      unless rebalance_amount.blank?
        self.contest_results.each do |w|
          w.payout_amount = rebalance_amount
          w.save
        end
      end
    end
  end

  def remove_user(user)
    self.users.delete(user) unless user.blank?

    #credit
    previous_payments = Payment.where(user: user, contest: self).where("payment_amount < 0")
    previous_unrefunded_payments = previous_payments.select{|item| item.credits.count == 0}
    total_unrefunded_payment_amount = previous_unrefunded_payments.map(&:payment_amount).sum

    Rails.logger.debug { "Unrefunded Amount: #{total_unrefunded_payment_amount} From # of Transactions: #{previous_unrefunded_payments.count}" }

    if total_unrefunded_payment_amount != 0
      refund = Payment.create(contest: self, payment_amount: total_unrefunded_payment_amount * -1.0, user: user, payment_source: "Contest Dues Credit")

      previous_unrefunded_payments.each do |p|
        p.credits << refund
        p.save
      end
    end
  end

  def users_not_signed_up
    tournament_user_ids = self.tournament_day.tournament.players_for_day(self.tournament_day).map { |n| n.id }
    ids_to_omit = self.users.map { |n| n.id }

    if ids_to_omit.blank?
      self.tournament_day.tournament.league.users.where("users.id IN (?)", tournament_user_ids).order(:last_name).order(:first_name)
    else
      self.tournament_day.tournament.league.users.where("users.id IN (?)", tournament_user_ids).where("users.id NOT IN (?)", ids_to_omit).order(:last_name).order(:first_name)
    end
  end

end
