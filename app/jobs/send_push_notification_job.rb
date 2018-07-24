class SendPushNotificationJob < ApplicationJob
  def perform(user, notification_string, tournament_id)
    user.send_mobile_notification(notification_string, { tournament_id: tournament_id })
  end
end
