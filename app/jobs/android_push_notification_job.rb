class AndroidPushNotificationJob < ApplicationJob
  queue_as :notifications

  def perform(user, body, extra_data = nil)
    return if Rails.env.development?

    firebase = FCM.new(FIREBASE_API_KEY)

    user.android_devices.each do |device|
      registration_ids = [device.device_identifier]

      options = {notification: {
        body: body,
        title: "EZ Golf League Update"
        }}

      response = firebase.send(registration_ids, options)

      Rails.logger.info { "Android Notification Response: #{response}" }
    end
  end
end
