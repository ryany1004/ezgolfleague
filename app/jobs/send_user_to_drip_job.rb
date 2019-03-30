class SendUserToDripJob < ApplicationJob
  def perform(user)
	  options = {
	    tags: user.drip_tags,
	    custom_fields: {
	      first_name: user.first_name,
	      last_name: user.last_name,
	    }
	  }

	  DRIP_CLIENT.create_or_update_subscriber(user.email, options)
  end
end
