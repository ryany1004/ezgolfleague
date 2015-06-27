class Contest < ActiveRecord::Base
  belongs_to :tournament, inverse_of: :contests
  
  #handle single winner contests
  belongs_to :overall_winner, :class_name => "ContestResult", :foreign_key => "overall_winner_contest_result_id", :dependent => :destroy
  
  #handle multiple hole contests
  has_many :contest_holes, :dependent => :destroy
  has_many :course_holes, through: :contest_holes  

  def human_type
    if self.contest_type == 0
      return "Overall Winner"
    else
      return "By Hole"
    end
  end
  
  def contest_results
    if self.contest_type == 0
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
  
  def can_accept_more_results?
    if self.contest_type == 0 && !self.overall_winner.blank?
      return false
    else
      return true
    end
  end
  
  def winners
    if self.contest_type == 0
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
