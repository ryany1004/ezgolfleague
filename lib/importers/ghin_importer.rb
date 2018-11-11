require 'open-uri'

module Importers
  class GHINImporter

    def self.import_for_all_users
      User.where("ghin_number IS NOT NULL").where("ghin_number != ''").where("ghin_updated_at <= ?", 5.minutes.ago).order(:ghin_updated_at).each do |u|
        Importers::GHINImporter.import_ghin_for_user(u)
      end
    end

    def self.recalc_course_handicap_for_user(user)
      tournaments = Tournament.tournaments_happening_at_some_point(nil, nil, user.leagues, true).where(is_finalized: false)
      tournaments.each do |t|
        t.tournament_days.each do |td|
          scorecard = td.primary_scorecard_for_user(user)

          unless scorecard.blank?
            puts "Updating Scorecard #{scorecard.id} Course Handicap for #{user.complete_name}"

            scorecard.set_course_handicap(true) #re-calc the course handicap

            td.touch
          end
        end
      end
    end

    def self.import_ghin_for_user(user)
      return nil if user.blank? || user.ghin_number.blank?

      user_failure_string = "NOT Updating for #{user.complete_name} / #{user.id}: "

      begin
        url = user.ghin_url

        puts "Reading: #{url}"
        doc = Nokogiri::HTML(open(url))

        unless doc.blank?
          root_node = doc.search("//td[@class='ClubGridHandicapIndex']")

          unless root_node.blank?
            handicap_index = root_node.children.last.children.to_s.to_f

            unless handicap_index.blank?
              puts "Handicap Index: #{handicap_index} for #{user.complete_name}"

              unless handicap_index == 0.0
                user.handicap_index = handicap_index
                user.ghin_updated_at = DateTime.now
                user.save

                Importers::GHINImporter.recalc_course_handicap_for_user(user)
              else
                puts user_failure_string + "Not Updating - Zero Value"
              end
            end
          else
            puts user_failure_string + "Root node was blank"
          end
        else
          puts user_failure_string + "Doc was blank"
        end
      rescue => e
        puts user_failure_string + "GHIN Exception: #{e}"
      end
    end

  end
end
