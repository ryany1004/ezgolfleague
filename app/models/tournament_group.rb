class TournamentGroup < ActiveRecord::Base
  include Servable
  
  belongs_to :tournament_day, inverse_of: :tournament_groups, :touch => true
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
  
  def formatted_tee_time
    return self.tee_time_at.to_s(:time_only)
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

  #JSON
  
  def as_json(options={})
    super(
      :only => [:tee_time_at],
      :methods => [:server_id],
      :include => {
        :teams => {
          :only => [:id],
          :methods => [:server_id],
          :include => {
            :golf_outings => {
              :only => [:course_handicap],
              :methods => [:server_id],
              :include => {
                :user => {
                  :only => [:first_name, :last_name],
                  :methods => [:server_id]
                },
                :course_tee_box => {
                  :only => [:name],
                  :methods => [:server_id]
                }
              }
            }
          }
        }
      }
    )
  end

end
