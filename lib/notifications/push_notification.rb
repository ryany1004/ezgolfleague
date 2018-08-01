module Notifications
	class PushNotification
		def send_notification(user, body, extra_data = nil)
			return if Rails.env.staging?

      begin
	    	if user.has_ios_devices?
					push_notifier = Notifications::IosPushNotification.new
	    		push_notifier.send_notification(user, body, extra_data)
				end

	    	if user.has_android_devices?
					push_notifier = Notifications::AndroidPushNotification.new
	    		push_notifier.send_notification(user, body, extra_data)
	    	end
      rescue => e
        Rails.logger.info { "PushNotification Error Sending Notification: #{e}" }
      end
		end
	end
end