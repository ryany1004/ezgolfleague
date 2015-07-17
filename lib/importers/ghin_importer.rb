require 'open-uri'

module Importers
  class GHINImporter
    
    def self.import_ghin_for_user(user)
      return nil if user.blank? || user.ghin_number.blank?
      
      url = "http://widgets.ghin.com/HandicapLookupResults.aspx?entry=1&ghinno=#{user.ghin_number}&css=default&dynamic=&small=0&mode=&tab=0"
      
      puts "Reading: #{url}"
      doc = Nokogiri::HTML(open(url))
      
      unless doc.blank?
        root_node = doc.search("//td[@class='ClubGridHandicapIndex']")
        
        unless root_node.blank?
          handicap_index = root_node.children.last.children.to_s.to_f
      
          puts "Handicap Index: #{handicap_index}"
      
          unless handicap_index.blank?
            user.handicap_index = handicap_index
            user.save
          end
        else
          puts "Root node was blank"
        end
      else
        puts "Doc was blank"
      end
    end
    
  end
end