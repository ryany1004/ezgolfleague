class NotificationMailer < ApplicationMailer

  def notification_message(user, subject, contents)
    @user = user
    @contents = contents

    mail(to: @user.email, subject: "EZ Golf League: #{subject}")
  end

end
