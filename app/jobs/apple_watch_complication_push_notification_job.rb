class AppleWatchComplicationPushNotificationJob < IosPushNotificationJob
  def perform(device, body, content_available = false, extra_data = nil)
    begin
      if device.environment_name == 'debug'
        pusher = IosPushNotificationJob.pusher(true)
      else
        pusher = IosPushNotificationJob.pusher
      end

      notification = Apnotic::Notification.new(device.device_identifier)
      notification.topic = 'com.ezgolfleague.GolfApp.complication'
      notification.content_available = 1
      notification.custom_payload = { data: extra_data }

      response = pusher.push(notification)

      Rails.logger.info { "Notification Response: #{response.headers} #{response.body}" } if response.present?

      pusher.close
    rescue SocketError => e
      Rails.logger.info { "Socket Error Sending Push Notification: #{e}" }
    rescue Errno::ECONNRESET => e
      Rails.logger.info { "Connection Reset Error Sending Push Notification: #{e}" }
    end
  end
end
