class ApplicationMailer < ActionMailer::Base
  default from: "support@ezgolfleague.com"
  layout 'mailer'

  before_action :check_before_sending

  private

  def check_before_sending
    if Rails.env.staging?
      mail.perform_deliveries = false
    end
  end
end
