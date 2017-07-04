module Importers
  class Sbjrgolf_Importer
    def import(filename)
      CSV.foreach(filename, {:headers => true, :header_converters => :symbol}) do |user|
        parent_user = User.where(first_name: user[:parent_first], last_name: user[:parent_last], email: user[:parent_email]).first
        if parent_user.blank?
          parent_user = User.create(first_name: user[:parent_first], last_name: user[:parent_last], email: user[:parent_email], password: SecureRandom.uuid, phone_number: user[:phone])
        end

        puts "Parent: #{parent_user.complete_name}"

        child_users = User.where(first_name: user[:golfer_first], last_name: user[:golfer_last])
        if child_users.count > 1
          puts "Child Users > 1 #{user[:golfer_first]} #{user[:golfer_last]}"
        else
          child_user = child_users.first

          if child_user.blank?
            child_user = User.create(first_name: user[:golfer_first], last_name: user[:golfer_last], email: "#{SecureRandom.uuid}@nobody.com", password: SecureRandom.uuid, phone_number: user[:phone])
          end
          
          child_user.parent_user = parent_user
          child_user.save

          puts "Set Parent #{parent_user.complete_name} for Child #{child_user.complete_name}"

          league = League.where(name: user[:league]).first
          unless league.blank?
            if !child_user.leagues.include? league
              puts "Assigned to League: #{league.id}"

              LeagueMembership.create(league: league, user: child_user)
            end
          end
        end
      end
    end
  end
end
