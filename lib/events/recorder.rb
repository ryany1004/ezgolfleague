module Events
  class Recorder
  	def self.record_event(email:, action:, properties: nil)
  		DRIP_CLIENT.track_event(email, action, properties) if Rails.env.production?
  	end

  	def self.record_event_for_users(emails:, action:, properties: nil)
  		emails.each do |email|
  			Events::Recorder.record_event(email: email, action: action, properties: properties)
  		end
  	end
  end
end