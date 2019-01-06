class IosPushNotificationJob < ApplicationJob
  def perform(device, body, content_available = false, extra_data = nil)
    return if Rails.env.development?
    
    begin
      if device.environment_name == "debug"
        pusher = self.pusher(true)
      else
        pusher = self.pusher
      end

      notification = Apnotic::Notification.new(device.device_identifier)
      notification.topic = "com.ezgolfleague.GolfApp"
      notification.content_available = 1 unless content_available.blank?
      notification.alert = body unless body.blank?
      notification.custom_payload = extra_data

      #add a thread id for grouping notifications if they are from the same tournament
      unless extra_data.blank? || extra_data[:tournament_id].blank?
        notification.thread_id = "tournament-#{extra_data[:tournament_id]}"
      end

      response = pusher.push(notification)

      Rails.logger.info { "Notification Response: #{response.headers} #{response.body}" }

      pusher.close
    rescue SocketError => e
      Rails.logger.info { "Socket Error Sending Push Notification: #{e}" }
    rescue Errno::ECONNRESET => e
      Rails.logger.info { "Connection Reset Error Sending Push Notification: #{e}" }
    end
  end

  def pusher(use_debug = false)
    certificate_file = "#{Rails.root}/config/apns_cert.pem"
    passphrase = "golf"

    if use_debug == true
      connection = Apnotic::Connection.development(cert_path: certificate_file, cert_pass: passphrase)
    else
      connection = Apnotic::Connection.new(cert_path: certificate_file, cert_pass: passphrase)
    end

    return connection
  end
end