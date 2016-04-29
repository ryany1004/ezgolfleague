class SendNotificationsJob < ProgressJob::Base
  def initialize()
    @templates = NotificationTemplate.where("deliver_at <= ?", DateTime.now).where("has_been_delivered = ?", false)

    super progress_max: @templates.count
  end

  def perform
    update_stage('Sending Notifications')

    pusher = User.pusher

    @templates.each do |t|
      t.recipients.each do |r|
        Notification.create(notification_template: t, user: r, title: t.title, body: t.body)

        NotificationMailer.notification_message(r, t.title, t.body).deliver_later if r.wants_email_notifications == true

        r.send_mobile_notification(t.title, pusher) if r.wants_push_notifications == true
      end

      t.has_been_delivered = true
      t.save

      update_progress
    end
  end
end
