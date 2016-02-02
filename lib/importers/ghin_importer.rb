require 'open-uri'

module Importers
  class GHINImporter
    
    def self.import_for_all_users
      User.where("ghin_number IS NOT NULL").order("updated_at").each do |u|
        Importers::GHINImporter.import_ghin_for_user(u)
      end
    end
    
    def self.import_ghin_for_user(user)
      return nil if user.blank? || user.ghin_number.blank?
      
      begin
        url = "http://widgets.ghin.com/HandicapLookupResults.aspx?entry=1&ghinno=#{user.ghin_number}&css=default&dynamic=&small=0&mode=&tab=0"
      
        puts "Reading: #{url}"
        doc = Nokogiri::HTML(open(url))
      
        unless doc.blank?
          root_node = doc.search("//td[@class='ClubGridHandicapIndex']")
        
          unless root_node.blank?
            handicap_index = root_node.children.last.children.to_s.to_f

            unless handicap_index.blank?
              puts "Handicap Index: #{handicap_index}"
            
              user.handicap_index = handicap_index
              user.save
            end
          else
            puts "Root node was blank"
          end
        else
          puts "Doc was blank"
        end        
      rescue => e
        puts "Exception: #{e}"
      end
    end
    
  end
end