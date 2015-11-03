require 'smarter_csv'

module Importers
  class UserImporter
    def import(filename)
      User.uncached do      
        file_lines = SmarterCSV.process(filename)
        
        Rails.logger.debug { "Number of Lines: #{file_lines.count}" }
      
        file_lines.each do |line|
          league = League.where("name = ?", line[:league_name]).first
          unless league.blank?
            Rails.logger.debug { "Importing For #{line[:player_last_name]}, #{line[:player_first_name]} #{line[:email]}" }
            
            player = self.find_or_create_player_in_league(line[:player_last_name], line[:player_first_name], line[:email], line[:phone_number], league)
            
            unless player.blank?
              LeagueMembership.create(user: player, league: league, league_dues_discount: line[:discount_amount], state: MembershipStates::ADDED)
            end
          else
            Rails.logger.debug { "No League, Skipping: #{line[:league_name]}" }
          end
        end
      end
    end
    
    def find_or_create_player_in_league(last_name, first_name, email, phone_number, league)
      return nil if email.blank?
      
      stripped_first_name = strip_string(first_name)
      stripped_last_name = strip_string(last_name)
      stripped_email = strip_string(email)
      stripped_email = stripped_email.downcase
           
      player = league.users.where("last_name = ? AND first_name = ? AND (email = ? OR email IS NULL)", stripped_last_name, stripped_first_name, stripped_email).first
      
      player = User.create!(first_name: stripped_first_name, last_name: stripped_last_name, password: "imported_user", email: stripped_email) if player.blank?   
      
      player.email = stripped_email
      player.phone_number = phone_number
      player.handicap_index = 0
      player.save
      
      return player
    end
    
    def strip_string(unstripped_string)
      return unstripped_string.strip
    end
  end
end