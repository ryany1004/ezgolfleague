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
    
    return true
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
        winners << {user: result.winner, result_value: result.result_value, amount: result.payout_amount, points: result.points}
      end

      winners.sort! { |x,y| x[:amount] <=> y[:amount] }

      return winners
    end
  end

end
