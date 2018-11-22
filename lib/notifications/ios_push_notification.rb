module Notifications
	class IosPushNotification < Notifications::PushNotification
	  def send_silent_notification(user, extra_data = nil)
	    return if !user.has_ios_devices?

	    user.ios_devices.each do |device|
	    	IosPushNotificationJob.perform_later(device, nil, true)
	    end
	  end

	  def send_notification(user, body, extra_data = nil)
	    pusher = IosPushNotification.pusher

	    user.ios_devices.each do |device|
	    	IosPushNotificationJob.perform_later(device, body, false, extra_data)
	    end
	  end

	  def send_complication_notification(user, content)
	  	user.apple_watch_devices.each do |device|
	  		AppleWatchComplicationPushNotificationJob.perform_later(device, nil, true, content)
	  	end
	  end
	end
end
