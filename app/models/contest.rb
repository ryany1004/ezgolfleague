class Contest < ActiveRecord::Base
  include ContestScoreable
  
  has_many :payments, inverse_of: :contest
  belongs_to :tournament_day, inverse_of: :contests, :touch => true
  
  #handle single winner contests
  belongs_to :overall_winner, :class_name => "ContestResult", :foreign_key => "overall_winner_contest_result_id", :dependent => :destroy
  
  #handle multiple hole contests
  has_many :contest_holes, :dependent => :destroy
  has_many :course_holes, through: :contest_holes  
  
  has_and_belongs_to_many :users #contestants

  def human_type
    if self.contest_type == 0
      return "Custom: Overall Winner"
    elsif self.contest_type == 1
      return "Custom: By Hole"
    elsif self.contest_type == 2
      return "Net Skins"
    elsif self.contest_type == 3
      return "Gross Skins"
    elsif self.contest_type == 4
      return "Net Low"
    elsif self.contest_type == 5
      return "Gross Low"
    elsif self.contest_type == 6
      return "Net Low Tournament Total"
    elsif self.contest_type == 7
      return "Gross Low Tournament Total"
    end
  end
  
  def manual_results_entry?
    if self.contest_type < 2
      return true
    else
      return false
    end
  end
  
  def contest_results
    if self.is_by_hole? == false
      if self.overall_winner.blank?
        return []      
      else
        return [self.overall_winner]
      end
    else      
      results = []
      
      self.contest_holes.each do |hole|
        hole.contest_results.each do |result|
          results << result
        end
      end
      
      return results
    end
  end
  
  def remove_results
    self.overall_winner = nil
    
    self.contest_holes.each do |hole|
      hole.contest_results.destroy_all
    end
  end
  
  def is_by_hole?
    return false if self.contest_type == 0
    return false if self.contest_type == 4
    return false if self.contest_type == 5
    return false if self.contest_type == 6
    return false if self.contest_type == 7
    
    return true
  end
  
  def should_sum_winners?
    return true if self.contest_type == 2
    return true if self.contest_type == 3
    
    return false
  end
  
  def can_accept_more_results?
    if self.contest_type == 0 && !self.overall_winner.blank?
      return false
    else
      return true
    end
  end
  
  def winners
    if self.is_by_hole? == false
      if self.overall_winner.blank?
        return nil
      else
        return [{user: self.overall_winner.winner, result_value: self.overall_winner.result_value, amount: self.overall_winner.payout_amount, points: self.overall_winner.points}]
      end
    else
      winners = []

      self.contest_results.each do |result|
        if self.should_sum_winners?
          existing_winner = nil
          winners.each do |w|
            existing_winner = w if w[:user] == result.winner
          end
          
          if existing_winner.blank?
            winners << {user: result.winner, result_value: result.result_value, amount: result.payout_amount, points: result.points, number_of_wins: 1}
          else
            existing_winner[:number_of_wins] += 1
            existing_winner[:amount] += result.payout_amount
            existing_winner[:points] += result.points
            
            existing_winner[:result_value] = "#{existing_winner[:number_of_wins]}"
          end
        else
          winners << {user: result.winner, result_value: result.result_value, amount: result.payout_amount, points: result.points}
        end
      end

      winners.sort! { |x,y| x[:amount] <=> y[:amount] }

      return winners
    end
  end
  
  def users_not_signed_up
    tournament_user_ids = self.tournament_day.tournament.players_for_day(self.tournament_day).map { |n| n.id }
    ids_to_omit = self.users.map { |n| n.id }
    
    if ids_to_omit.blank?
      return self.tournament_day.tournament.league.users.where("users.id IN (?)", tournament_user_ids).order("last_name, first_name")
    else
      return self.tournament_day.tournament.league.users.where("users.id IN (?)", tournament_user_ids).where("users.id NOT IN (?)", ids_to_omit).order("last_name, first_name")
    end
  end

end
