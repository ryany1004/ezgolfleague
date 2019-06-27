require 'open-uri'

module Importers
  class GHINImporter
    def self.import_for_all_users
      User.where('ghin_number IS NOT NULL').where("ghin_number != ''").where('ghin_updated_at <= ?', 5.minutes.ago).includes(:tournaments).order(:ghin_updated_at).each do |u|
        if u.tournaments.where('tournament_starts_at > ?', Time.zone.now)
          Importers::GHINImporter.import_ghin_for_user(u)

          sleep 1
        end
      end
    end

    def self.recalc_course_handicap_for_user(user)
      tournaments = Tournament.tournaments_happening_at_some_point(nil, nil, user.leagues, true).where(is_finalized: false).includes(:tournament_days)
      tournaments.each do |t|
        t.tournament_days.each do |td|
          scorecard = td.primary_scorecard_for_user(user)

          if scorecard.present?
            Rails.logger.info { "Updating Scorecard #{scorecard.id} Course Handicap for #{user.complete_name}" }

            scorecard.set_course_handicap(true)
            td.touch # explicit touch needed because updating the course handicap skips callbacks
          end
        end
      end
    end

    def self.import_ghin_for_user(user)
      return nil if user.blank? || user.ghin_number.blank?

      begin
        url = user.ghin_url

        Rails.logger.info { "Reading: #{url}" }
        doc = Nokogiri::HTML(open(url))

        if doc.present?
          root_node = doc.search("//td[@class='ClubGridHandicapIndex']")

          if root_node.present?
            handicap_index = root_node.children.last.children.to_s.to_f

            if handicap_index.present?
              Rails.logger.info { "Handicap Index: #{handicap_index} for #{user.complete_name}" }

              unless handicap_index.zero?
                user.handicap_index = handicap_index
                user.ghin_updated_at = Time.zone.now
                user.save

                Importers::GHINImporter.recalc_course_handicap_for_user(user)
              else
                Rails.logger.info { 'Not Updating - Zero Value' }
              end
            end
          else
            Rails.logger.info { 'Root node was blank' }
          end
        else
          Rails.logger.info { 'Doc was blank' }
        end
      rescue => e
        Rails.logger.info { "GHIN Exception: #{e}" }
      end
    end
  end
end
