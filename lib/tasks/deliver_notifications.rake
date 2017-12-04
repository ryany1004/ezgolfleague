namespace :deliver_notifications do
  desc 'Deliver Pending Notifications'
  task pending: :environment do
    SendNotificationsJob.perform_later
  end
end
