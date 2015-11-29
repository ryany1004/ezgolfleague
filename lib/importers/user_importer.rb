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
            
            player = self.find_or_create_player(line[:player_last_name], line[:player_first_name], line[:email], line[:phone_number], line[:ghin])
            
            unless player.blank?
              existing_membership = league.users.where("user_id = ?", player.id)
              
              LeagueMembership.create(user: player, league: league, league_dues_discount: line[:discount_amount], state: MembershipStates::ADDED) if existing_membership.blank?
            end
          else
            Rails.logger.debug { "No League, Skipping: #{line[:league_name]}" }
          end
        end
      end
    end
    
    def find_or_create_player(last_name, first_name, email, phone_number, ghin_number)
      return nil if email.blank?
      
      stripped_first_name = strip_string(first_name)
      stripped_last_name = strip_string(last_name)
      stripped_email = strip_string(email)
      stripped_email = stripped_email.downcase
      stripped_ghin = strip_string(ghin_number)
      
      player = User.where("last_name = ? AND first_name = ? AND (email = ? OR email LIKE ? OR email IS NULL)", stripped_last_name, stripped_first_name, stripped_email, "%imported.com%").first
      
      player = User.create!(first_name: stripped_first_name, last_name: stripped_last_name, password: "imported_user", email: stripped_email) if player.blank?   
      
      player.email = stripped_email
      player.phone_number = phone_number
      player.ghin_number = stripped_ghin
      player.save
      
      return player
    end
    
    def strip_string(unstripped_string)
      return unstripped_string.strip
    end
  end
end