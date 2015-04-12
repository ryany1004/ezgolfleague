class TournamentGroup < ActiveRecord::Base
  belongs_to :tournament, inverse_of: :tournament_groups
  has_many :teams, inverse_of: :tournament_group, :dependent => :destroy
  
  paginates_per 50
  
  def players_signed_up
    players = []
    
    self.teams.each do |t|
      t.golf_outings.each do |g|
        players << g.user
      end
    end
    
    return players
  end
  
  #date parsing
  def tee_time_at=(date)
    begin
      parsed = DateTime.strptime("#{date} #{Time.zone.now.formatted_offset}", JAVASCRIPT_DATETIME_PICKER_FORMAT)
      super parsed
    rescue
      write_attribute(:tee_time_at, date)
    end
  end
  
end