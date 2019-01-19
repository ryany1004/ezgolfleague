DRIP_CLIENT = Drip::Client.new do |c|
	if Rails.env.production? # do not sent to Drip in non production environments
  	c.api_key = "5ae846f226b923247442a56a00e43a5c"
  	c.account_id = "2656310"
	end
end