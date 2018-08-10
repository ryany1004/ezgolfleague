class ApplicationJob < ActiveJob::Base
	before_perform do |job|
		ActiveRecord::Base.clear_active_connections! #for Resque
	end
end
