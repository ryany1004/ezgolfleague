module Notifications
	class PushNotification
		def send_notification(user, body, extra_data = nil)
    	if user.has_ios_devices?
				push_notifier = Notifications::IosPushNotification.new
    		push_notifier.send_notification(self, body, extra_data)
			end

    	if user.has_android_devices?
				push_notifier = Notifications::AndroidPushNotification.new
    		push_notifier.send_notification(self, body, extra_data)
    	end
		end
	end
end