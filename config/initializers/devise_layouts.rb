# Specify the layout file that should be used for each Devise controller
EzgolfRails::Application.configure do
  config.to_prepare do
    Devise::SessionsController.layout       "login"
    Devise::RegistrationsController.layout  "login"
    Devise::ConfirmationsController.layout  "login"
    Devise::UnlocksController.layout        "login"
    Devise::PasswordsController.layout      "login"
  end
end