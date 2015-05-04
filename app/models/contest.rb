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
      return [self.overall_winner]
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
      return {user: self.overall_winner.user, amount: self.overall_winner.payout_amount}
    else
      winners = []

      self.contest_results.each do |result|
        winners << {user: result.winner, amount: result.payout_amount}
      end

      return winners
    end
  end

end