class Tournament < ActiveRecord::Base
  belongs_to :league, inverse_of: :tournaments
  belongs_to :course, inverse_of: :tournaments
  has_many :tournament_groups, -> { order(:tee_time_at) }, inverse_of: :tournament, :dependent => :destroy
  has_and_belongs_to_many :course_holes, -> { order(:hole_number) }
  
  validates :name, presence: true
  validates :tournament_at, presence: true
  validates :signup_opens_at, presence: true
  
  paginates_per 50
  
  def includes_player?(user)
    player_included = false
    
    self.tournament_groups.each do |group|
      group.players_signed_up.each do |player|
        player_included = true if player == user
      end
    end
    
    return player_included
  end
  
  def player_score(user)
    return nil if !self.includes_player?(user)

    total_score = 0

    self.tournament_groups.each do |group|
      group.teams.each do |team|
        team.golf_outings.each do |golf_outing|
          if golf_outing.user == user
            golf_outing.scorecards.first.scores.each do |score|
              total_score = total_score + score.strokes
            end
          end
        end
      end
    end
    
    return total_score
  end
  
  def add_player_to_group(tournament_group, user)
    Tournament.transaction do
      team = Team.create!(tournament_group: tournament_group)
      outing = GolfOuting.create!(team: team, user: user)
      scorecard = Scorecard.create!(golf_outing: outing)
      
      self.course_holes.each do |hole|
        score = Score.create!(scorecard: scorecard, course_hole: hole)
      end
    end
  end
  
  def remove_player_from_group(tournament_group, user)
    tournament_group.teams.each do |team|
      team.golf_outings.each do |outing|
        if outing.user = user
          outing.destroy
          
          team.destroy if team.golf_outings.count == 0
          
          break
        end
      end
    end
  end
  
  #date parsing
  def tournament_at=(date)
    begin
      parsed = DateTime.strptime("#{date} #{Time.zone.now.formatted_offset}", JAVASCRIPT_DATETIME_PICKER_FORMAT)
      super parsed
    rescue
      write_attribute(:tournament_at, date)
    end
  end
  
  def signup_opens_at=(date)
    begin
      parsed = DateTime.strptime("#{date} #{Time.zone.now.formatted_offset}", JAVASCRIPT_DATETIME_PICKER_FORMAT)
      super parsed
    rescue
      write_attribute(:signup_opens_at, date)
    end
  end
  
  def signup_closes_at=(date)
    begin
      parsed = DateTime.strptime("#{date} #{Time.zone.now.formatted_offset}", JAVASCRIPT_DATETIME_PICKER_FORMAT)
      super parsed
    rescue
      write_attribute(:signup_closes_at, date)
    end
  end
  
end