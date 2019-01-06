class RecordEventJob < ApplicationJob
  def perform(email_addresses, action, properties = nil)
    Events::Recorder.record_event_for_users(email_addresses, action, properties)
  end
end
