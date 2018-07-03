namespace :memcached do
  desc 'Clear Cache'
  task clear: :environment do
    Rails.cache.clear
  end
end