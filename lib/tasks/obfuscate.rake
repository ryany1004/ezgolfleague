namespace :obfuscate do
  desc 'Obfuscate Local Data'
  task names_emails: :environment do
    non_leagues = League.where('id NOT IN (?)', [6, 19, 134, 898])
    non_leagues.destroy_all

    User.all.each do |u|
      u.update(email: Faker::Internet.email, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name)
    end

    user = User.create(email: 'developer@ezgolfleague.com', password: 'developer123', first_name: 'EZGL', last_name: 'Developer')
    LeagueMembership.create(league: League.find(6), user: user, is_admin: true)
    LeagueMembership.create(league: League.find(19), user: user, is_admin: true)
    LeagueMembership.create(league: League.find(134), user: user, is_admin: true)
    LeagueMembership.create(league: League.find(898), user: user, is_admin: true)
  end
end
