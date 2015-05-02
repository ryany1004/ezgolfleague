class Contest < ActiveRecord::Base
  belongs_to :tournament, inverse_of: :contests
  belongs_to :overall_winner, :class_name => "ContestResult", :foreign_key => "overall_winner_contest_result_id", :dependent => :destroy
  accepts_nested_attributes_for :overall_winner
  
  has_many :contest_holes, :dependent => :destroy
  has_many :course_holes, through: :contest_holes
  has_many :contest_results, through: :contest_holes

  def human_type
    if self.contest_type == 0
      return "Overall Winner"
    else
      return "By Hole"
    end
  end
  
  def winners
    return "X"
  end
  
end
