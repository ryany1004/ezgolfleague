class GhinUpdateJob < ProgressJob::Base
  def initialize(users)
    super progress_max: users.count

    @users = users
  end

  def perform
    update_stage('Updating Users')

    @users.each_with_index do |u, i|
      Importers::GHINImporter.import_ghin_for_user(u)

      if i > 0 and i % 8 == 0 #their system seems to get mad if we are too aggressive
        Rails.logger.info { "GHIN Updater Taking a Nap..." }

        sleep 30
      end

      update_progress
    end
  end

end
