require 'sidekiq/web'

Rails.application.routes.draw do
  default_url_options host: 'app.ezgolfleague.com' if Rails.env.production?

  devise_for :users

  root to: 'dashboard#index', constraints: ->(r) { r.env['warden'].authenticate? && r.env['warden'].user.is_any_league_admin? }, as: :league_admin_root
  root to: 'play/dashboard#index'

  get 'apple-app-site-association', to: 'api/v1/tournaments#app_association'
  get '.well-known/apple-app-site-association', to: 'api/v1/tournaments#app_association'

  authenticate :user, ->(user) { user.is_super_user } do
    mount Sidekiq::Web => '/jobs'
  end

  # this is for playing tournaments
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
        resources :scoring_rules, only: [:index]
      end
    end

    resources :registrations, only: [:new, :create] do
      get :leagues, on: :collection
      get :leagues_list, on: :collection
      get :join_league, on: :collection
      get :new_league, on: :collection
      get :add_golfers, on: :collection
      post :invite_golfers, on: :collection
      post :create_league, on: :collection
      post :submit_payment, on: :collection
      put :request_information, on: :collection
      get :setup_completed, on: :collection
    end

    resource :user_account, only: [:edit, :update], controller: 'user_account' do
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
      put 'switch_users'
    end
  end

  # API
  namespace :api do
    namespace :v1 do
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
      end

      resources :scores do
        put 'batch_update', on: :collection
      end

      resources :payments, only: [:create]

      resources :leagues, only: [:index, :show]

      resources :tournaments do
        get 'results'
        get 'validate_tournaments_exist', on: :collection

        resources :tournament_days, only: [:show] do
          post 'register'
          put 'cancel_registration'
          get 'payment_details'

          post 'register_contests'
          post 'register_optional_games'

          get 'tournament_groups'
          get 'leaderboard'

          resources :scorecards, only: [:show]
        end
      end
    end

    namespace :v2 do
      resources :courses do
        resources :course_tee_boxes
      end

      resources :scorecards

      resources :leagues do
        resources :scoring_rules, only: [:index]

        resource :tournament_wizard, only: [:create]

        resources :tournaments do
          resources :tournament_days do
            resources :flights
            resources :tournament_groups
            resources :scoring_rules
            resources :golfer_details, only: [:show, :update, :destroy]
          end
        end
      end
    end
  end

  # this is for admin
  resources :dashboard, only: [:index] do
    put 'switch_leagues', on: :collection
  end

  resources :leagues do
    patch 'update_from_ghin'
    patch 'update_calculated_handicaps'
    patch 'update_league_standings'
    get 'switch_seasons'

    resources :subscription_credits, except: :show do
      post 'update_credit_card', on: :collection
      put 'update_active', on: :collection
    end

    resources :league_seasons

    resources :league_memberships do
      get 'print', on: :collection
      post 'update_handicaps', on: :collection
    end

    resources :tournaments do
      resource :finalization, path: 'finalize', only: [:show, :update], controller: 'tournaments/finalization'
    end
  end

  resources :prints do
    get 'print_scorecards', on: :collection
    get 'run_print_scorecards', on: :collection
    get 'print_display_scorecards', on: :collection
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

    patch 'export_users', on: :collection

    get 'impersonate'
    get 'stop_impersonating', on: :collection
  end

  resources :crontab do
    get 'send_tournament_registration_emails', on: :collection
    get 'send_tournament_registration_reminder_emails', on: :collection
    get 'update_all_players_from_ghin', on: :collection
    get 'send_tournament_registration_status', on: :collection
    get 'send_tournament_coming_up_emails', on: :collection
  end
end
