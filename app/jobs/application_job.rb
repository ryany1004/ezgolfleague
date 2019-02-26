class ApplicationJob < ActiveJob::Base
	include Rollbar::ActiveJob

	before_perform do |job|
		ActiveRecord::Base.clear_active_connections!
	end
end
