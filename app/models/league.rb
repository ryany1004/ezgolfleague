class League < ActiveRecord::Base
  has_many :league_seasons, :dependent => :destroy
  has_many :league_memberships, :dependent => :destroy
  has_many :users, through: :league_memberships
  has_many :tournaments, :dependent => :destroy, inverse_of: :league
  has_many :payments, inverse_of: :league
  
  validates :name, presence: true
  validates :credit_card_fee_percentage, numericality: { greater_than_or_equal_to: 0.01, less_than_or_equal_to: 1.0 }
  
  paginates_per 50
  
  attr_encrypted :stripe_test_secret_key, :key => ENCRYPYTED_ATTRIBUTES_KEY
  attr_encrypted :stripe_production_secret_key, :key => ENCRYPYTED_ATTRIBUTES_KEY
  attr_encrypted :stripe_test_publishable_key, :key => ENCRYPYTED_ATTRIBUTES_KEY
  attr_encrypted :stripe_production_publishable_key, :key => ENCRYPYTED_ATTRIBUTES_KEY
  
  def stripe_publishable_key
    if self.stripe_test_mode == true
      return self.stripe_test_publishable_key
    else
      return self.stripe_production_publishable_key
    end
  end
  
  def stripe_secret_key
    if self.stripe_test_mode == true
      return self.stripe_test_secret_key
    else
      return self.stripe_production_secret_key
    end
  end
  
  def membership_for_user(user)
    return self.league_memberships.where(user: user).first
  end
  
  def dues_for_user(user)
    membership = user.league_memberships.where("league_id = ?", self.id).first

    unless membership.blank?
      dues_amount = self.dues_amount
      discount_amount = dues_amount - membership.league_dues_discount
      credit_card_fees = self.credit_card_fee_percentage * discount_amount
      
      return discount_amount + credit_card_fees
    else
      return 0
    end
  end
  
  def state_for_user(user)
    membership = self.membership_for_user(user)
    
    return membership.state
  end

  def user_has_paid?(user)
    balance = 0.0
    
    self.payments.where(user: user).each do |p|
      balance = balance + p.payment_amount
    end
    
    if balance == 0.0
      return true
    else
      return false
    end
  end
  
  def ranked_users_for_year(starts_at, ends_at)
    ranked_players = []
    
    tournaments = Tournament.tournaments_happening_at_some_point(starts_at, ends_at, [self])
    tournaments.each do |t|
      t.players.each do |p|
        points = 0
        t.tournament_days.each do |day|
          points = day.player_points(p)
        end
        
        found_existing_player = false
      
        ranked_players.each do |r|
          if r[:id] == p.id
            r[:points] = r[:points] + points
          
            found_existing_player = true
          end
        end
    
        if found_existing_player == false
          ranked_players << { id: p.id, name: p.complete_name, points: points, ranking: 0 }
        end
      end
    end
    
    ranked_players.sort! { |x,y| y[:points] <=> x[:points] }
    
    #now that players are sorted by points, rank them
    last_rank = 0
    last_points = 0
    quantity_at_rank = 0
    
    ranked_players.each_with_index do |player, i|
      #rank = last rank + 1
      #unless last_points are the same, then rank does not change
      #when last_points then does differ, need to move the rank up the number of slots

      if player[:points] != last_points
        rank = last_rank + 1
        
        if quantity_at_rank != 0
          quantity_at_rank = 0
          
          rank = i + 1
        end
        
        last_rank = rank
        last_points = player[:points]
      else
        rank = last_rank
        
        quantity_at_rank = quantity_at_rank + 1
      end
        
      player[:ranking] = rank
    end
    
    return ranked_players
  end
  
  def users_not_signed_up_for_tournament(tournament, tournament_day, extra_ids_to_omit)
    if tournament_day.blank?
      tournament_users = tournament.players
    else
      tournament_users = tournament.players_for_day(tournament_day)
    end
    
    ids_to_omit = tournament_users.map { |n| n.id }
    
    extra_ids_to_omit.each do |eid|
      ids_to_omit << eid
    end
    
    if ids_to_omit.blank?
      return self.users.order("last_name, first_name")
    else
      return self.users.where("users.id NOT IN (?)", ids_to_omit).order("last_name, first_name")
    end
  end
  
end
