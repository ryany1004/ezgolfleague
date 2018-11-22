module Notifications
	class AndroidPushNotification < Notifications::PushNotification
	  def send_notification(user, body, extra_data = nil)
	  	AndroidPushNotificationJob.perform_later(user, body, extra_data)
	  end
	end
end