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
    elsif self.contest_type == 8
      self.score_total_skins_contest
    end
  end
  
  def score_total_skins_contest
    Rails.logger.debug { "Scoring Total Skins Contest" }
    
    self.remove_results
    self.save
    
    gross_winners = self.users_with_skins(true, true)
    net_winners = self.users_with_skins(false, false)
    
    all_winners = []
    
    gross_winners.each do |w|
      all_winners << w
    end
    
    net_winners.each do |w|
      all_winners << w
    end
    
    self.calculate_skins_winners(all_winners)
  end
  
  def score_skins_contest(use_gross)
    self.remove_results
    self.save
    
    all_winners = self.users_with_skins(use_gross)
    
    self.calculate_skins_winners(all_winners)
  end
  
  def calculate_skins_winners(all_winners)
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
  
  def users_with_skins(use_gross, gross_skins_require_birdies = false)
    all_winners = []
    
    self.course_holes.each do |hole|
      users_getting_skins = []
      gross_birdie_skins = []
      user_scores = []

      self.users.each do |user|
        if self.tournament_day.tournament.includes_player?(user)
          score = self.tournament_day.compute_player_score(user, use_gross, holes = [hole.hole_number])

          unless score.blank? || score == 0
            if gross_skins_require_birdies == true #check if gross birdie                            
              gross_birdie_skins << user if score <= (hole.par - 1) #gross birdies or better count
              
              Rails.logger.info { "User #{user.complete_name} scored a gross birdie skin for hole #{hole.hole_number} w/ score #{score}" }
            else #regular counting              
              user_scores << {user: user, score: score}
            end
          else
            Rails.logger.info { "Score Blank - Not Scoring Contest. This is weird. #{user.complete_name}" }
          end
        else
          Rails.logger.info { "Tournament Day Does Not Include Contest Player - This is Weird. #{user.complete_name}" }
        end
      end

      if gross_skins_require_birdies == true
        gross_birdie_skins.each do |user|          
          users_getting_skins << user
        end
      else
        user_scores.sort! { |x,y| x[:score] <=> y[:score] }
        
        unless user_scores.blank?
          if user_scores.count == 1                    
            users_getting_skins << user_scores[0][:user]
            
            Rails.logger.info { "User #{user_scores[0][:user].complete_name} scored a regular skin for hole #{hole.hole_number}" }
          elsif user_scores.count > 1        
            if user_scores[0] != user_scores[1] #if there is a tie, they do not count
              users_getting_skins << user_scores[0][:user] 
            
              Rails.logger.info { "User #{user_scores[0][:user].complete_name} scored a regular skin for hole #{hole.hole_number}" }
            end
          end
        end
      end

      all_winners << {hole: hole, winners: users_getting_skins}
    end

    return all_winners
  end
  
  def score_net_contest(use_gross, across_all_days = false)
    self.overall_winner = nil
    self.save

    eligible_player_ids = self.tournament_day.game_type.eligible_players_for_payouts

    results = []
    if across_all_days == true
      self.tournament_day.tournament.tournament_days.each do |td|
        td.tournament_day_results.each do |result|
          if eligible_player_ids.include? result.user.id and self.users.include? result.user
            Rails.logger.debug { "Player Eligible for Contest: #{result.user.id}" }
            
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
          else
            Rails.logger.debug { "Player Not Eligible for Contest: #{result.user}" }
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
      if self.overall_winner_payout_amount.blank?
        total_value = self.users.count * self.dues_amount #automatic distribution
      else
        total_value = self.overall_winner_payout_amount
      end
                  
      winner = results[0][:user]
      result_value = results[0][:score]

      self.overall_winner = ContestResult.create(winner: winner, payout_amount: total_value, result_value: "#{result_value}", points: self.overall_winner_points)
      self.save
    end
  end
  
end