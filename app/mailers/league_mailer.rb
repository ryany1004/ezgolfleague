class LeagueMailer < ApplicationMailer
  
  def league_message(user, subject, contents)
    @user = user
    @contents = contents

    mail(to: @user.email, subject: "League Message: #{subject}")
  end
  
end
