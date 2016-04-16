class GhinUpdateJob < ProgressJob::Base
  def initialize(users)
    super progress_max: users.count

    @users = users
  end

  def perform
    update_stage('Updating Users')

    @users.each_with_index do |u, i|
      Importers::GHINImporter.import_ghin_for_user(u)

      sleep 30 if i % 8 == 0 #their system seems to get mad if we are too aggressive

      update_progress
    end
  end

end
