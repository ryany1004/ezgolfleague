namespace :deliver_notifications do
  desc 'Deliver Pending Notifications'
  task pending: :environment do
    Delayed::Job.enqueue SendNotificationsJob.new()
  end
end
