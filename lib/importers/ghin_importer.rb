require 'open-uri'

module Importers
  class GHINImporter
    
    def self.import_ghin_for_user(user)
      return nil if user.blank? || user.ghin_number.blank?
      
      url = "http://widgets.ghin.com/HandicapLookupResults.aspx?entry=1&ghinno=#{user.ghin_number}&css=default&dynamic=&small=0&mode=&tab=0"
      doc = Nokogiri::HTML(open(url))
      handicap_index = doc.search("//td[@class='ClubGridHandicapIndex']").children.last.children.to_s.to_f
      
      logger.info { "HI: #{handicap_index}" }
      
      unless handicap_index.blank?
        user.handicap_index = handicap_index
        user.save
      end
    end
    
  end
end