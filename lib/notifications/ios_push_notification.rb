module Notifications
	class IosPushNotification < Notifications::PushNotification
	  def send_silent_notification(user, extra_data = nil)
# 	    return if !user.has_ios_devices?

# 	    pusher = IosPushNotification.pusher

# 	    user.ios_devices.each do |device|
# 	      pusher = IosPushNotification.pusher(true) if device.environment_name == "debug"

# 	      notification = Apnotic::Notification.new(device.device_identifier)
# 	      notification.topic = "com.ezgolfleague.GolfApp"
# 	      notification.content_available = 1
# 	      notification.custom_payload = extra_data

# 	      response = pusher.push(notification)

# 	      Rails.logger.info { "Notification Response: #{response.headers} #{response.body}" }
# 	    end

# 	    pusher.close
	  end

	  def send_notification(user, body, extra_data = nil)
# 	    pusher = IosPushNotification.pusher

# 	    user.ios_devices.each do |device|
# 	      pusher = IosPushNotification.pusher(true) if device.environment_name == "debug"

# 	      notification = Apnotic::Notification.new(device.device_identifier)
# 	      notification.topic = "com.ezgolfleague.GolfApp"
# 	      notification.alert = body
# 	      notification.custom_payload = extra_data

# 	      Rails.logger.info { "Pushing Standard Notification to #{device.device_identifier} #{device.environment_name}" }

# 	      response = pusher.push(notification)

# 	      Rails.logger.info { "Notification Response: #{response.headers} #{response.body}" }
# 	    end

# 	    pusher.close
	  end

	  def self.pusher(use_debug = false)
	    certificate_file = "#{Rails.root}/config/apns_cert.pem"
	    passphrase = "golf"

	    if use_debug == true
	      connection = Apnotic::Connection.development(cert_path: certificate_file, cert_pass: passphrase)
	    else
	      connection = Apnotic::Connection.new(cert_path: certificate_file, cert_pass: passphrase)
	    end

	    return connection
	  end

	  def send_complication_notification(user, content)
# 	    user.apple_watch_devices.each do |device|
# 	      certificate_file = "#{Rails.root}/config/apns_complication_cert.pem"
# 	      passphrase = "golf"

# 	      if device.environment_name == "debug"
# 	        pusher = Apnotic::Connection.development(cert_path: certificate_file, cert_pass: passphrase)
# 	      else
# 	        pusher = Apnotic::Connection.new(cert_path: certificate_file, cert_pass: passphrase)
# 	      end

# 	      notification = Apnotic::Notification.new(device.device_identifier)
# 	      notification.topic = "com.ezgolfleague.GolfApp.complication"
# 	      notification.content_available = 1
# 	      notification.custom_payload = {data: content}

# 	      Rails.logger.info { "Pushing Complication Notification to #{device.device_identifier} #{device.environment_name}" }

# 	      response = pusher.push(notification)

# 	      Rails.logger.info { "Notification Response: #{response.headers} #{response.body}" }

# 	      pusher.close
# 	    end
	  end

	end
end
