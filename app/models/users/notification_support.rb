module Users
	module NotificationSupport
	  def ios_devices
	    self.mobile_devices.where(device_type: "iphone")
	  end

	  def apple_watch_devices
	    self.mobile_devices.where(device_type: "apple-watch-complication")
	  end

	  def android_devices
	    self.mobile_devices.where(device_type: "android")
	  end

	  def has_ios_devices?
	    self.ios_devices.count >= 1
	  end

	  def has_apple_watch_devices?
	    self.apple_watch_devices.count >= 1
	  end

	  def has_android_devices?
	    self.android_devices.count >= 1
	  end

	  def send_mobile_notification(body, extra_data = nil)
	    return if self.wants_push_notifications == false

	    push_notifier = ::Notifications::PushNotification.new
	    push_notifier.send_notification(self, body, extra_data)
	  end

	  def send_silent_notification(extra_data = nil)
	    return if !self.has_ios_devices?

	    push_notifier = ::Notifications::IosPushNotification.new
	    push_notifier.send_silent_notification(self, extra_data)
	  end

	  def send_complication_notification(content)
	    return if !self.has_apple_watch_devices?

	    push_notifier = ::Notifications::IosPushNotification.new
	    push_notifier.send_complication_notification(self, content)
	  end
	end
end