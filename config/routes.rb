Rails.application.routes.draw do
  if Rails.env.production? #TODO: split this for staging / production
    default_url_options :host => "app.ezgolfleague.com"
  end
  
  devise_for :users
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
    
  root to: 'tournaments#index', constraints: -> (r) { r.env["warden"].authenticate? && r.env['warden'].user.is_any_league_admin? }, as: :league_admin_root
  root to: 'play/dashboard#index'
  
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
      resources :sessions, only: [:create]
      
      resources :scores do
        put 'batch_update', on: :collection
      end
      
      resources :tournaments do
        resources :tournament_days, only: [:show] do
          get 'tournament_groups'
          get 'leaderboard'
        end
      end
    end
  end
  
  #this is for admin
  resources :leagues do    
    resources :league_seasons
    
    resources :league_memberships do
      get 'print', on: :collection
    end
    
    resources :tournaments do #this is for setting them up
      resources :tournament_days do
        resources :flights, only: [:create, :update] do
          resources :payouts, only: [:new, :edit, :create, :update]
        end
        resources :tournament_groups, only: [:create, :update]
        resources :golfer_teams, only: [:create, :update]
        resources :contests, only: [:create, :update] do
          resources :contest_results, only: [:new, :create, :update]
        end
      end
      
      resource :game_types do
        get 'options', on: :collection
      end
    
      resources :golfer_teams
      
      resources :flights do
        patch 'reflight_players', on: :collection
        
        resources :payouts
      end
    
      resources :contests do
        resources :contest_results
        
        get 'registrations'
        delete 'remove_registration'
        post 'add_registration'
      end
    
      resources :tournament_groups do
        post 'batch_create', on: :collection
      end
   
      get 'manage_holes'
      patch 'update_holes'
      
      patch 'auto_schedule'
   
      get 'signups'
      post 'add_signup'
      delete 'delete_signup'
      patch 'update_auto_schedule'
      
      get 'confirmed_players'
      
      get 'finalize'
      get 'run_finalization'
      get 'display_finalization'
      patch 'confirm_finalization'
      
      patch 'update_course_handicaps'
      patch 'touch_tournament'
    end
    
    patch 'update_from_ghin'
    
    get 'write_member_email'
    post 'send_member_email'
  end
  
  resources :payments
  
  resources :scorecards, :except => [:delete] do
    get 'print', on: :collection
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
  end
  
  resources :crontab do
    get 'send_tournament_registration_emails', on: :collection
    get 'send_tournament_registration_reminder_emails', on: :collection
    get 'update_all_players_from_ghin', on: :collection
  end
  
end
