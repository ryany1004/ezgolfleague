FactoryBot.define do
  factory :user do
    email { "hunter@lastonepicked.com" }
    first_name { "Hunter" }
    last_name { "Hillegas" }
    handicap_index { 12 }
    password { "testtest" }
    phone_number { "999-111-1111" }

    factory :user_with_mobile_devices do
        transient do
    	   mobile_devices_count { 1 }
    	   mobile_device_type { "unknown" }
    	end

    	after(:create) do |user, evaluator|
    		create_list(:mobile_device, evaluator.mobile_devices_count, user: user, device_type: evaluator.mobile_device_type)
    	end
    end
  end
end
