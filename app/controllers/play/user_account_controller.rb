class Play::UserAccountController < Play::BaseController
    layout "golfer"

    before_action :fetch_user, only: [:edit, :update, :password, :change_password]
    before_action :initialize_form, only: [:edit]

    def edit
    end

    def update
      if @user_account.update(user_params)
        redirect_to play_dashboard_index_path, flash: { success: "Your profile was successfully updated." }
      else
        initialize_form

        render :edit
      end
    end

    def password
    end

    def change_password
      if @user_account.update(user_params)
        sign_in(@user_account, bypass: true)

        redirect_to play_dashboard_index_path, flash: { success: "Your password was successfully updated." }
      else
        render :password
      end
    end

    private

    def user_params
      params.require(:user).permit! #TODO: Update
    end

    def fetch_user
      @user_account = current_user
    end

    def initialize_form
      @us_states = GEO_STATES
      @countries = COUNTRIES
    end

end
