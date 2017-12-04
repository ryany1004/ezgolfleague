class GhinUpdateJob < ApplicationJob
  def perform(users)
    users.each_with_index do |u, i|
      Importers::GHINImporter.import_ghin_for_user(u)

      if i > 0 and i % 8 == 0 #their system seems to get mad if we are too aggressive
        Rails.logger.info { "GHIN Updater Taking a Nap..." }

        sleep 30
      end
    end

    Rails.logger.info { "GHIN Update Job Complete" }
  end

end
