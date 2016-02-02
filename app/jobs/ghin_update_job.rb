class GhinUpdateJob < ProgressJob::Base
  def initialize(users)
    super progress_max: users.count
    
    @users = users
  end

  def perform
    update_stage('Updating Users')
    
    @users.each do |u|
      Importers::GHINImporter.import_ghin_for_user(u)
      
      update_progress
    end
  end
  
end