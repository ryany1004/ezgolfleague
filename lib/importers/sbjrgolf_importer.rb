module Importers
  class Sbjrgolf_Importer
    def import(filename)
      CSV.foreach(filename, {:headers => true, :header_converters => :symbol}) do |user|
        parent_user = User.where(first_name: user[:parent_first], last_name: user[:parent_last], email: user[:parent_email]).first
        if parent_user.blank?
          parent_user = User.create(first_name: user[:parent_first], last_name: user[:parent_last], email: user[:parent_email], password: SecureRandom.uuid, phone_number: user[:phone])
        end

        child_users = User.where(first_name: user[:golfer_first], last_name: user[:golfer_last])
        if child_users.count > 1
          puts "Child Users > 1 #{user[:golfer_first]} #{user[:golfer_last]}"
        else
          child_user = child_users.first

          if child_user.blank?
            child_user = User.create(first_name: user[:golfer_first], last_name: user[:golfer_last], email: "#{SecureRandom.uuid}@nobody.com", password: SecureRandom.uuid, phone_number: user[:phone])
          end
          child_user.parent_user = parent_user

          league = League.where(name: user[:league]).first
          child_user.leagues << league unless league.blank?
        end
      end
    end
  end
end
