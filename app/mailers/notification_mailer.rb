class NotificationMailer < ApplicationMailer

  def notification_message(user, from, subject, contents)
    @user = user
    @contents = contents

    mail(to: @user.email, from: from, subject: "EZ Golf League: #{subject}")
  end

end
