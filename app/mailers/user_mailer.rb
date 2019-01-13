class UserMailer < ApplicationMailer
  def invite(email_address, league)
  	email_address = email_address.strip
  	@league = league

  	mail(to: email_address, from: 'support@ezgolfleague.com', subject: "You've been invited to join #{league.name} via EZ Golf League")
  end
end
