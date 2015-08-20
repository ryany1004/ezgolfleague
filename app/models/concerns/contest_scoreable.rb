module ContestScoreable
  extend ActiveSupport::Concern
  
  def score_contest
    if self.contest_type == 2
      self.score_skins_contest(false)
    elsif self.contest_type == 3
      self.score_skins_contest(true)
    elsif self.contest_type == 4
      self.score_net_contest(false)
    elsif self.contest_type == 5
      self.score_net_contest(true)
    end
  end
  
  def score_skins_contest(use_gross)
    self.contest_results.destroy_all
    
    all_winners = []
  
    self.course_holes.each do |hole|
      users_getting_skins = []
      user_scores = []
      
      self.users.each do |user|
        score = self.tournament_day.player_score(user, !use_gross, holes = [hole.hole_number])
        
        unless score.blank?
          user_scores << {user: user, score: score}
        
          #check if gross birdie
          if use_gross == true
            gross_score = score
          else
            gross_score = self.tournament_day.player_score(user, true, holes = [hole.hole_number])
          end
        
          if gross_score == (hole.par - 1)
            users_getting_skins << user
          end
        end
      end
      
      user_scores.sort! { |x,y| x[:score] <=> y[:score] }
      users_getting_skins << user_scores[0][:user]
      
      all_winners << {hole: hole, winners: users_getting_skins}
    end
    winners_sum = 0
    all_winners.each do |w|
      winners_sum += w[:winners].count
    end
        
    value_per_skin = (self.users.count * self.dues_amount) / winners_sum
    
    all_winners.each do |winner_info|
      hole = winner_info[:hole]
      contest_hole = self.contest_holes.where(course_hole: hole).first
      
      winner_info[:winners].each do |winner|
        ContestResult.create(contest: self, winner: winner, payout_amount: value_per_skin, contest_hole: contest_hole, result_value: "Hole #{hole.hole_number}")
      end
    end
  end
  
  def score_net_contest(use_gross)
    self.overall_winner = nil
    self.save
    
    if use_gross == true
      sort_by = "gross_score DESC"
    else
      sort_by = "net_score DESC"
    end
    
    total_value = self.users.count * self.dues_amount
    
    results = self.tournament_day.tournament_day_results.order(sort_by)
    results.each do |result|
      if use_gross == true
        result_value = result.gross_score
      else
        result_value = result.net_score
      end
      
      self.users.each do |u|
        if result.user == u
          self.overall_winner = ContestResult.create(winner: u, payout_amount: total_value, result_value: "#{result_value}")
          self.save
          
          return
        end
      end
    end
    
  end
  
end