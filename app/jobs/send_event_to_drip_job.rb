class SendEventToDripJob < ApplicationJob
  queue_as :notifications
  
  def perform(event_name, user:, options:)
  	DRIP_CLIENT.track_event(user.email, event_name, options)
  end
end
