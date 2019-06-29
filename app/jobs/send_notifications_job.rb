class SendNotificationsJob < ApplicationJob
  def perform
    @templates = NotificationTemplate.where('deliver_at <= ?', Time.zone.now).where(has_been_delivered: false)

    @templates.each do |t|
      t.has_been_delivered = true
      t.save

      next if t.sent_to_all? # helps prevent situations with 'runaway' notifications that are somehow getting sent again and again

      t.recipients.each do |r|
        Notification.create(notification_template: t, user: r, title: t.title, body: t.body)

        email_from = 'support@ezgolfleague.com'

        if t.league.blank?
          subject = t.title
        else
          subject = "#{t.league.name} - #{t.title}"
          email_from = t.league.league_admins.first.email
        end

        # email
        begin
          NotificationMailer.notification_message(r, email_from, subject, t.body).deliver_later if r.wants_email_notifications && r.valid?
        rescue => e
          Rails.logger.info { "Error Sending Email Notification: #{e}" }
        end

        # push
        begin
          r.send_mobile_notification("#{t.title}: #{t.body}") if r.wants_push_notifications
        rescue => e
          Rails.logger.info { "Error Sending Push Notification: #{e}" }
        end
      end
    end
  end
end
