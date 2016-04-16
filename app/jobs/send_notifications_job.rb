class SendNotificationsJob < ProgressJob::Base
  def initialize()
    @templates = NotificationTemplate.where("deliver_at < ?", DateTime.now).where("has_been_delivered = ?", false)

    super progress_max: @templates.count
  end

  def perform
    update_stage('Sending Notifications')

    @templates.each do |t|
      t.recipients.each do |r|
        Notification.create(notification_template: t, user: r, title: t.title, body: t.body)

        NotificationMailer.notification_message(r, t.title, t.body).deliver_later if r.wants_email_notifications == true
        # self.send_push_notification(r.device_identifier, t.title, t.body) if r.wants_push_notifications == true
      end

      t.has_been_delivered = true
      t.save

      update_progress
    end
  end

  def send_push_notification(device_identifier, title, body)
    #TODO
  end

end