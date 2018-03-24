class SendNotificationsJob < ApplicationJob
  def perform
    @templates = NotificationTemplate.where("deliver_at <= ?", DateTime.now).where("has_been_delivered = ?", false)

    @templates.each do |t|
      t.recipients.each do |r|
        Notification.create(notification_template: t, user: r, title: t.title, body: t.body)

        if t.league.blank?
          subject = t.title
        else
          subject = "#{t.league.name} - #{t.title}"
        end

        NotificationMailer.notification_message(r, subject, t.body).deliver_later if r.wants_email_notifications == true

        r.send_mobile_notification(t.title) if r.wants_push_notifications == true
      end

      t.has_been_delivered = true
      t.save
    end
  end
end
