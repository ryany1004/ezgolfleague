class GhinUpdateJob < ProgressJob::Base
  def initialize(users)
    all_users = []

    #this is a HUGE hack
    all_users = users.shuffle + users.shuffle + users.shuffle

    super progress_max: all_users.count

    @users = all_users
  end

  def perform
    update_stage('Updating Users')

    @users.each_with_index do |u, i|
      Importers::GHINImporter.import_ghin_for_user(u)

      if i % 10 == 0
        sleep 20
      end

      update_progress
    end
  end

end
