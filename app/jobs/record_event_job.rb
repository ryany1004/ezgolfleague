class RecordEventJob < ApplicationJob
  def perform(email_addresses, action, properties = nil)
    Events::Recorder.record_event_for_users(emails: email_addresses, action: action, properties: properties)
  end
end