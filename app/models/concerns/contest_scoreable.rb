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
    elsif self.contest_type == 6
      self.score_net_contest(false, true)
    elsif self.contest_type == 7
      self.score_net_contest(true, true)
    end
  end
  
  def score_skins_contest(use_gross)
    self.remove_results
    self.save
    
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
      users_getting_skins << user_scores[0][:user] unless user_scores.blank?
      
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
  
  def score_net_contest(use_gross, across_all_days = false)
    self.overall_winner = nil
    self.save

    results = []
    if across_all_days == true
      self.tournament_day.tournament.tournament_days.each do |td|
        td.tournament_day_results.each do |result|
          existing_user = nil
        
          results.each do |r|
            existing_user = r if r[:user] == result.user
          end
          
          if existing_user.blank?
            if use_gross == true
              results << {user: result.user, score: result.gross_score} unless result.gross_score.blank?
            else
              results << {user: result.user, score: result.net_score} unless result.net_score.blank?
            end
          else
            if use_gross == true
              existing_user[:score] += result.gross_score
            else
              existing_user[:score] += result.net_score
            end
          end
        end
      end
    else
      self.tournament_day.tournament_day_results.each do |result|
        if use_gross == true
          results << {user: result.user, score: result.gross_score} unless result.gross_score.blank?
        else
          results << {user: result.user, score: result.net_score} unless result.net_score.blank?
        end
      end
    end
    
    Rails.logger.debug { "#{results}" }
    
    #sort
    results.sort! { |x,y| x[:score] <=> y[:score] }
    
    #set winner
    unless results.blank? || results.count == 0
      total_value = self.users.count * self.dues_amount
                  
      winner = results[0][:user]
      result_value = results[0][:score]
      
      self.overall_winner = ContestResult.create(winner: winner, payout_amount: total_value, result_value: "#{result_value}")
      self.save
    end
  end
  
end