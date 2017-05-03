Rails.application.routes.draw do
  if Rails.env.production?
    default_url_options :host => "app.ezgolfleague.com"
  end

  devise_for :users

  root to: 'tournaments#index', constraints: -> (r) { r.env["warden"].authenticate? && r.env['warden'].user.is_any_league_admin? }, as: :league_admin_root
  root to: 'play/dashboard#index'

  get 'apple-app-site-association', to: 'api/v1/tournaments#app_association'
  get '.well-known/apple-app-site-association', to: 'api/v1/tournaments#app_association'

  #this is for playing tournaments
  namespace :play do
    resources :payments, only: [:index, :new, :create] do
      get 'thank_you', on: :collection
      get 'error', on: :collection
    end

    resources :tournaments, only: [:show] do
      get 'leaderboard'
      get 'signup'

      put 'complete_signup'
      delete 'remove_signup'

      put 'confirm'

      resources :tournament_days, only: [:index] do
        resources :contests, only: [:index]
      end
    end

    resources :registrations, only: [:new, :create] do
      get :leagues, on: :collection
      post :search_leagues, on: :collection
      get :league_info, on: :collection
      get :join_league, on: :collection
      get :new_league, on: :collection
      post :create_league, on: :collection
      post :submit_payment, on: :collection
      put :request_information, on: :collection
    end

    resource :user_account, only: [:edit, :update], controller: "user_account" do
      get 'password'
      patch 'change_password'
    end

    resources :scorecards, only: [:show, :update] do
      patch 'finalize_scorecard'
      patch 'become_designated_scorer'
      patch 'update_game_type_metadata'
    end

    resources :dashboard, only: [:index] do
      put 'switch_leagues'
      put 'switch_seasons'
    end
  end

  #API
  namespace "api" do
    namespace "v1" do
      get 'current_day_leaderboard' => 'scorecards#current_day_leaderboard'

      resources :sessions, only: [:create] do
        post 'register_device', on: :collection
        post 'upload_avatar_image', on: :collection
      end

      resources :registrations, only: [:create] do
        get 'search_leagues', on: :collection
        get 'league_tournament_info', on: :collection
        get 'notify_interest', on: :collection
        post 'pay_dues', on: :collection
        post 'create_league', on: :collection
      end

      resources :scores do
        put 'batch_update', on: :collection
      end

      resources :payments, only: [:create]

      resources :tournaments do
        get 'validate_tournaments_exist', on: :collection

        resources :tournament_days, only: [:show] do
          post 'register'
          put 'cancel_registration'
          get 'payment_details'

          get 'tournament_groups'
          get 'leaderboard'

          resources :scorecards, only: [:show]
        end
      end
    end
  end

  #this is for admin
  resources :leagues do
    get 'new_subscription'
    get 'setup_subscription'
    get 'view_subscription'
    put 'update_subscription'

    resources :league_seasons

    resources :league_memberships do
      get 'print', on: :collection
      put 'update_active', on: :collection
    end

    resources :reports do
      get 'adjusted_scores', on: :collection
      get 'confirmed_players', on: :collection
    end

    resources :tournaments do #this is for setting them up
      resources :tournament_days do
        resources :flights, only: [:create, :update] do
          resources :payouts, only: [:new, :edit, :create, :update]
        end
        resources :tournament_groups, only: [:create, :update]
        resources :contests, only: [:create, :update] do
          resources :contest_results, only: [:new, :create, :update]
        end
      end

      get 'tournament_days/:tournament_day_id/players' => 'golf_outings#players', as: :day_players
      post 'tournament_days/:tournament_day_id/update_players' => 'golf_outings#update_players', as: :update_day_players
      patch 'tournament_days/:tournament_day_id/disqualify_signup' => 'golf_outings#disqualify_signup', as: :disqualify_day_players
      delete 'tournament_days/:tournament_day_id/delete_signup' => 'golf_outings#delete_signup', as: :delete_day_players

      resource :game_types do
        get 'options', on: :collection
      end

      resources :flights do
        patch 'reflight_players', on: :collection
      end

      resources :payouts

      resources :contests do
        resources :contest_results

        get 'registrations'
        delete 'remove_registration'
        post 'add_registration'
      end

      resources :tournament_groups do
        post 'batch_create', on: :collection
      end

      resources :tournament_notifications

      get 'manage_holes'
      patch 'update_holes'

      patch 'auto_schedule'
      patch 'update_auto_schedule'

      get 'finalize'
      get 'run_finalization'
      get 'display_finalization'
      patch 'confirm_finalization'

      patch 'update_course_handicaps'
      patch 'touch_tournament'
      patch 'rescore_players'
    end

    patch 'update_from_ghin'
  end

  resources :payments

  resources :notification_templates do
    put 'duplicate_template'
  end

  resources :prints do
    get 'print_scorecards', on: :collection
    get 'run_print_scorecards', on: :collection
    get 'print_display_scorecards', on: :collection
  end

  resources :scorecards, :except => [:delete] do
    patch 'disqualify'
  end

  resources :courses do
    resources :course_tee_boxes

    resources :course_holes do
      resources :course_hole_tee_boxes
    end
  end

  resources :user_accounts do
    get 'edit_current', on: :collection

    get 'setup_league_admin_invite', on: :collection
    post 'send_league_admin_invite', on: :collection

    patch 'resend_league_invite'

    get 'setup_golfer_invite', on: :collection
    post 'send_golfer_invite', on: :collection

    get 'impersonate'
    get 'stop_impersonating', on: :collection
  end

  resources :crontab do
    get 'send_tournament_registration_emails', on: :collection
    get 'send_tournament_registration_reminder_emails', on: :collection
    get 'update_all_players_from_ghin', on: :collection
  end

end
