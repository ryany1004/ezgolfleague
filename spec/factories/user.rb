FactoryGirl.define do
  factory :user do
    email "hunter@lastonepicked.com"
    is_super_user true
    first_name "Hunter"
    last_name "Hillegas"
    handicap_index 12
    password "testtest"
    phone_number "999-111-1111"
  end
end
